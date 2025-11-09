# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## High-level code architecture and structure

This project is a proxy server written in Go that provides a unified API for various AI models, including OpenAI, Gemini, and Claude. It uses the Gin framework for handling HTTP requests.

The application's entry point is in `cmd/server/main.go`, which handles command-line flags, loads the configuration, and starts the appropriate service. The core logic for handling API requests is located in the `internal/api` directory, with specific handlers for different models in subdirectories.

The configuration is defined in `internal/config/config.go` and is loaded from a `config.yaml` file. The configuration includes settings for the server port, authentication, logging, and API keys for the various AI models.

## Commonly used commands

### Build and run the application

To build and run the application, you can use the `docker-build.sh` script, which provides options to either run a pre-built image or build from source.

To build from source and run:
```bash
./docker-build.sh # Select option 2
```

To run a pre-built image:
```bash
./docker-build.sh # Select option 1
```

### Run tests

This repository does not contain any tests.

### Run linters

This repository does not contain any linters.
