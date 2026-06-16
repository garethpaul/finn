.PHONY: build check lint test

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3
SWIFTC ?= swiftc

check:
	@if command -v "$(SWIFTC)" >/dev/null 2>&1; then \
		SWIFTC="$(SWIFTC)" "$(ROOT)/scripts/run-api-response-policy-tests.sh"; \
	else \
		echo "swiftc unavailable; executable restaurant API response tests skipped"; \
	fi
	@PYTHON="$(PYTHON)" "$(ROOT)/scripts/check-baseline.sh"

lint: check

test: check

build: check
