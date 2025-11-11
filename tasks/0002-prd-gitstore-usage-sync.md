# Product Requirements Document: Git-based Synchronization for Usage Statistics

| | |
|---|---|
| **Title** | Git-based Synchronization for Usage Statistics |
| **Version** | 1.0 |
| **Status** | Proposed |
| **Author** | Kilo Code |
| **Date** | 2025-11-11 |

---

## 1. Overview

This document outlines the requirements for a new feature that enables the persistence and cross-device synchronization of usage statistics (`usage.json`) using a Git repository as the backend storage mechanism (referred to as `gitstore`). This feature will provide users with a way to maintain a consistent view of their usage data across multiple instances of the application.

## 2. Problem Statement

Currently, usage statistics are persisted to a local file (`usage.json`), as defined by the `statistics-file` configuration parameter. This approach has the following limitations:

*   **Data Siloing:** Usage data is confined to the machine where the application is running. Users who run the application on multiple devices have fragmented and incomplete usage statistics.
*   **Data Loss Risk:** The usage data is not backed up. If the local file is lost or corrupted, the usage history is gone.
*   **Inconsistent State:** When running multiple instances of the proxy, there is no central source of truth for usage data.

This feature aims to solve these problems by leveraging the existing `gitstore` functionality to treat `usage.json` as a managed file within a Git repository, similar to how authentication tokens and configuration files are handled.

## 3. Goals and Objectives

*   **Goal 1: Centralize Usage Statistics:** Provide a mechanism to store `usage.json` in a remote Git repository, making it the single source of truth.
*   **Goal 2: Enable Cross-Device Synchronization:** Ensure that usage data is automatically synchronized across all application instances connected to the same `gitstore` repository.
*   **Goal 3: Improve Data Resilience:** Reduce the risk of data loss by versioning `usage.json` in a Git repository.
*   **Goal 4: Maintain Simplicity:** The feature should be easy to configure and should operate automatically in the background with minimal user intervention.
## 4. Functional Requirements

### 4.1. Configuration

A new section will be added to the `config.yaml` file to control the usage statistics synchronization.

```yaml
# in config.yaml

gitstore:
  # ... existing gitstore configuration (remote, username, password) ...
  usage-sync:
    # When true, enables synchronization of usage.json via gitstore.
    # This requires the main gitstore remote to be configured.
    enabled: false

    # The local path to the usage statistics file within the gitstore repository.
    # Defaults to 'usage/usage.json' inside the git repository.
    # The final absolute path will be <gitstore-repo-dir>/usage/usage.json
    path: "usage/usage.json"

    # Frequency for automatic background synchronization (pull and push).
    # The value should be a duration string (e.g., "15m", "1h").
    # A push is only triggered if the usage file has changed.
    # A pull is always attempted before writing to ensure the latest version is used.
    # Set to "0m" to disable periodic sync and only sync on shutdown.
    # Defaults to "15m".
    sync-interval: "15m"
```

### 4.2. Behavior

*   When `gitstore.usage-sync.enabled` is `true`:
    *   The application will use the path specified in `gitstore.usage-sync.path` (relative to the `gitstore` repository root) as the location for `usage.json`.
    *   The `statistics-file` configuration will be ignored in favor of the `gitstore` path.
    *   The application will automatically perform a `git pull` before writing to the `usage.json` file to ensure it is working with the latest version.
    *   The application will periodically commit and push `usage.json` to the remote repository if any changes have been made.
*   The synchronization interval will be configurable via `gitstore.usage-sync.sync-interval`.
*   A final synchronization will be attempted during graceful shutdown of the application to ensure the latest data is persisted.
*   If `gitstore.usage-sync.enabled` is `false` or the `gitstore` section is not configured, the application will fall back to using the `statistics-file` path as it does currently.

### 4.3. Synchronization Strategy

To balance efficiency and data freshness, the following synchronization strategy is proposed:

1.  **Periodic Sync (Default: 15 minutes):**
    *   A background process will run at the interval defined by `sync-interval`.
    *   It will check if `usage.json` has been modified locally.
    *   If there are changes, it will commit and push the file to the remote repository.
    *   This prevents excessive commits when there is no API activity.

2.  **Sync on Write (Pull-before-Push):**
    *   Before the application writes updated statistics to `usage.json`, it will first attempt to `git pull` the latest changes from the remote repository. This minimizes the risk of merge conflicts by ensuring the local version is up-to-date before modification.

3.  **Sync on Shutdown:**
    *   When the application receives a shutdown signal, it will trigger a final sync to push any pending usage data changes to the remote repository.

This hybrid approach ensures that data is kept reasonably up-to-date without creating a high volume of commits, while also protecting against data loss on shutdown.

## 5. Technical Requirements

*   The existing `internal/store/gitstore.go` module should be extended or utilized to handle the synchronization of `usage.json`. The `PersistAuthFiles` method is a good candidate for reuse, as it provides a generic way to commit and push specified files.
*   The usage manager (`internal/usage/logger_plugin.go`) will need to be modified to be aware of the `gitstore` configuration.
*   When `gitstore` sync is enabled, the usage manager should:
    *   Initialize with the correct file path inside the `gitstore` repository.
    *   Implement the "pull-before-write" logic.
    *   Launch a background ticker to handle periodic synchronization based on `sync-interval`.
    *   Register a shutdown hook to perform the final sync.
*   The main application startup logic (`cmd/server/main.go`) will need to orchestrate the setup of the usage manager with the `gitstore` instance.

## 6. Out of Scope

*   **Merge Conflict Resolution:** This feature will not automatically resolve merge conflicts in `usage.json`. The "pull-before-write" strategy is designed to minimize this risk. In the rare event of a conflict, manual intervention in the Git repository will be required. The `usage.json` file is a simple key-value store, so conflicts should be rare if all clients are pulling before writing.
*   **UI/API for Manual Sync:** A manual synchronization trigger via the management API is not part of this initial version but could be considered for a future iteration.

## 7. Open Questions

*   **Performance Impact:** What is the performance overhead of the "pull-before-write" operation?
    *   **Answer:** This is expected to be minimal for a small file like `usage.json`. The `git pull` operation is fast on a repository with a small number of files and a linear history. The benefit of preventing data corruption outweighs the minor latency.