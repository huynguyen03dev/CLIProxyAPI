## Relevant Files

- `internal/config/config.go` - Contains the main configuration structs that need to be extended.
- `internal/store/gitstore.go` - This file will house the core logic for file synchronization.
- `internal/usage/logger_plugin.go` - The usage manager that will trigger the synchronization.
- `cmd/server/main.go` - The application entrypoint where the new service will be initialized and managed.

### Notes

- Unit tests should be created for the new synchronization logic in `internal/store/gitstore_test.go`.
- Use `go test ./internal/store` to run the tests for the `store` package.

## Tasks

- [ ] 1.0 Extend `gitstore` configuration to support usage statistics synchronization.
  - [ ] 1.1 Define a new `UsageSync` struct in `internal/config/config.go` with `Enabled`, `Path`, and `SyncInterval` fields.
  - [ ] 1.2 Add the `UsageSync` struct to the `GitStore` configuration struct.
  - [ ] 1.3 Set default values for the new configuration fields in the `LoadConfig` function.
- [ ] 2.0 Implement the core synchronization logic within the `gitstore` service.
  - [ ] 2.1 Create a new method in `internal/store/gitstore.go` to handle periodic synchronization of a specified file.
  - [ ] 2.2 Implement "pull-before-write" logic to minimize merge conflicts.
  - [ ] 2.3 The method should accept a callback function to perform the file update.
- [ ] 3.0 Integrate the `gitstore` synchronization with the usage statistics manager.
  - [ ] 3.1 Modify `internal/usage/logger_plugin.go` to be aware of the `gitstore` configuration.
  - [ ] 3.2 Update the `Save` method to use the new `gitstore` sync method instead of writing directly to the file system.
  - [ ] 3.3 Update the `Load` method to pull the initial `usage.json` from the `gitstore`.
- [ ] 4.0 Orchestrate the setup of the usage sync service in the main application entrypoint.
  - [ ] 4.1 In `cmd/server/main.go`, check if `gitstore.usage-sync.enabled` is true after loading the configuration.
  - [ ] 4.2 If enabled, initialize and start the background synchronization service.
- [ ] 5.0 Ensure data is persisted on shutdown.
  - [ ] 5.1 Add a shutdown hook in `cmd/server/main.go`.
  - [ ] 5.2 The shutdown hook should trigger a final synchronization of the `usage.json` file.