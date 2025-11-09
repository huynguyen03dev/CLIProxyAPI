## Relevant Files

- `internal/config/config.go` - To add the new configuration field for the statistics file path.
- `internal/usage/logger_plugin.go` - To implement the `Load()` and `Save()` methods for statistics persistence.
- `cmd/server/main.go` - To integrate the loading and saving logic into the application's startup and shutdown sequences.
- `config.yaml.example` - To update the example configuration with the new `statistics_file` setting.

### Notes

- The project does not currently have a testing suite. For now, manual verification will be required.
- Configuration changes require updating both the Go struct and the example `config.yaml` file.

## Tasks

- [ ] 1.0 Add configuration for statistics file path
  - [ ] 1.1 Add a `StatisticsFile` field of type `string` to the `Config` struct in `internal/config/config.go`, with the YAML tag `statistics_file`.
  - [ ] 1.2 Update the `config.yaml.example` file to include the new `statistics_file` option, providing a commented-out example path.
- [ ] 2.0 Implement loading statistics from file on startup
  - [ ] 2.1 Create a new `Load(filePath string)` method for the `RequestStatistics` struct in `internal/usage/logger_plugin.go`.
  - [ ] 2.2 In the `Load` method, read the contents of the file at `filePath`. If the file doesn't exist, log a message and return without error.
  - [ ] 2.3 Unmarshal the JSON content into a `StatisticsSnapshot` struct.
  - [ ] 2.4 If loading and unmarshalling are successful, update the `RequestStatistics` instance with the data from the loaded snapshot.
- [ ] 3.0 Implement saving statistics to file on shutdown
  - [ ] 3.1 Create a new `Save(filePath string)` method for the `RequestStatistics` struct in `internal/usage/logger_plugin.go`.
  - [ ] 3.2 In the `Save` method, call the existing `Snapshot()` method to get the current usage data.
  - [ ] 3.3 Marshal the `StatisticsSnapshot` struct into an indented JSON format.
  - [ ] 3.4 Write the resulting JSON data to the file at `filePath`, overwriting it if it already exists.
- [ ] 4.0 Integrate loading and saving into the application lifecycle
  - [ ] 4.1 In `cmd/server/main.go`, after initializing the statistics logger, check if `UsageStatisticsEnabled` is true and `StatisticsFile` is configured. If so, call the `Load()` method.
  - [ ] 4.2 In `cmd/server/main.go`, implement a graceful shutdown mechanism that listens for interrupt signals.
  - [ ] 4.3 As part of the graceful shutdown logic, check if `UsageStatisticsEnabled` is true and `StatisticsFile` is configured. If so, call the `Save()` method.
