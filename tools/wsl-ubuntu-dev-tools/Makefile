SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

SCRIPTS_DIR := scripts

# List of individual tools (ordered logically so node precedes claude-code)
TOOLS := aws-cli azure-cli node claude-code docker gcloud-cli go java k8s-tools python terraform vault-cli

.PHONY: help base-tools install-all start $(TOOLS)

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "%-28s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

base-tools: ## Run baseline/prerequisite installation script
	@bash $(SCRIPTS_DIR)/install-tools.sh

# Explicit dependency: claude-code requires node first
claude-code: node

# Ensure base-tools runs before iterating through the rest
install-all: base-tools $(TOOLS) ## Install base prerequisites followed by all individual tools

# Pattern rule for individual tools (e.g., `make docker` will first run `make base-tools`)
$(TOOLS): base-tools
	@bash $(SCRIPTS_DIR)/install-$@.sh
