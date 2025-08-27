# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
GOMOD=$(GOCMD) mod
GOLINT=golangci-lint
GOFMT=gofumpt

# Binary name
BINARY_NAME=yai
BINARY_PATH=bin/$(BINARY_NAME)

# Build flags
LDFLAGS=-ldflags "-s -w"

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help message
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the binary
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p bin
	$(GOBUILD) $(LDFLAGS) -o $(BINARY_PATH) -v .
	@echo "Binary built at $(BINARY_PATH)"

.PHONY: run
run: ## Run the application
	$(GOCMD) run main.go

.PHONY: test
test: ## Run all tests with coverage
	@echo "Running tests..."
	$(GOTEST) -v -failfast -race -coverpkg=./... -covermode=atomic -coverprofile=coverage.txt ./...

.PHONY: test-short
test-short: ## Run tests without race detector (faster)
	@echo "Running tests (short)..."
	$(GOTEST) -v -short -cover ./...

.PHONY: lint
lint: ## Run linter
	@echo "Running linter..."
	$(GOLINT) run

.PHONY: lint-fix
lint-fix: ## Run linter with auto-fix
	@echo "Running linter with auto-fix..."
	$(GOLINT) run --fix

.PHONY: fmt
fmt: ## Format code
	@echo "Formatting code..."
	$(GOFMT) -w .

.PHONY: deps
deps: ## Download dependencies
	@echo "Downloading dependencies..."
	$(GOMOD) download

.PHONY: tidy
tidy: ## Tidy and verify dependencies
	@echo "Tidying dependencies..."
	$(GOMOD) tidy

.PHONY: clean
clean: ## Remove build artifacts
	@echo "Cleaning..."
	@rm -rf bin/ coverage.txt *.out *.test

.PHONY: install
install: build ## Install binary to $GOPATH/bin
	@echo "Installing $(BINARY_NAME)..."
	@cp $(BINARY_PATH) $(GOPATH)/bin/$(BINARY_NAME)
	@echo "Installed to $(GOPATH)/bin/$(BINARY_NAME)"

.PHONY: all
all: clean deps fmt lint test build ## Run all checks and build

.PHONY: check
check: fmt lint test ## Run all checks (format, lint, test)