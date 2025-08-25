# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Yai (Your AI) is a terminal assistant that uses OpenAI ChatGPT API to build and run commands based on natural language descriptions. It's a Go-based TUI application built with the Bubble Tea framework.

## Commands

### Build and Development
- **Run the application**: `go run main.go`
- **Build binary**: `go build -o yai`
- **Install dependencies**: `go mod download`
- **Update dependencies**: `go mod tidy`

### Testing
- **Run all tests**: `go test -v -failfast -race -coverpkg=./... -covermode=atomic -coverprofile=coverage.txt ./...`
- **Run tests for specific package**: `go test -v ./ai/...` (replace `ai` with desired package)
- **Run with coverage**: `go test -cover ./...`

### Linting
- **Run linter**: `golangci-lint run`
- **Auto-fix issues**: `golangci-lint run --fix`
- **Format code**: `gofumpt -w .`

The project uses specific linters configured in `.golangci.yml`: thelper, gofumpt, tparallel, unconvert.

## Architecture

### Core Modules

1. **`ai/`** - AI engine integration with OpenAI
   - `engine.go`: Main AI engine that handles ChatCompletion API calls
   - Supports chat and exec modes with streaming responses
   - Handles proxy configuration for API calls

2. **`ui/`** - Terminal UI built with Bubble Tea
   - `ui.go`: Main UI model implementing tea.Model interface
   - `prompt.go`: Input prompt handling with different modes (Exec, Chat, Rerun)
   - `renderer.go`: Markdown rendering using glamour
   - `spinner.go`: Loading indicators during AI operations

3. **`config/`** - Configuration management using Viper
   - Stores config in `~/.config/yai.json`
   - Manages OpenAI API key, model preferences, user context
   - Proxy settings for API calls

4. **`run/`** - Command execution
   - `runner.go`: Executes shell commands returned by AI
   - Handles command confirmation and execution with proper output formatting

5. **`history/`** - Command history management
   - Tracks executed commands and chat history
   - Provides history browsing capabilities

6. **`system/`** - System information analyzer
   - Detects OS, distribution, shell, editor preferences
   - Provides context to AI for better command generation

### Key Dependencies
- **charmbracelet/bubbletea**: TUI framework for the interactive interface
- **charmbracelet/glamour**: Markdown rendering in terminal
- **sashabaranov/go-openai**: OpenAI API client
- **spf13/viper**: Configuration management

### Message Flow
1. User input → UI → AI Engine
2. AI Engine → OpenAI API (with system context)
3. OpenAI API → Stream response → UI
4. For exec mode: AI response → Runner → Shell execution → Output

### Testing Approach
- Unit tests for each module (files ending in `_test.go`)
- Uses `stretchr/testify` for assertions
- Tests should be run with race detection enabled