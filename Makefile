.PHONY: build check lint test

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3
SWIFTC ?= swiftc

check:
	@if command -v "$(SWIFTC)" >/dev/null 2>&1; then \
		SWIFTC="$(SWIFTC)" "$(ROOT)/scripts/run-api-response-policy-tests.sh"; \
		SWIFTC="$(SWIFTC)" "$(ROOT)/scripts/run-finn-boundary-policy-tests.sh"; \
		"$(PYTHON)" "$(ROOT)/scripts/test-finn-boundary-mutations.py"; \
	else \
		echo "swiftc unavailable; executable Finn boundary tests and mutations skipped"; \
	fi
	@"$(PYTHON)" "$(ROOT)/scripts/test-finn-network-boundaries.py" \
		"$(ROOT)/Finn/API.swift" \
		"$(ROOT)/Finn/Picture.swift" \
		"$(ROOT)/Finn/RemoteImagePolicy.swift" \
		"$(ROOT)/Finn/FinnPickerView.swift" \
		"$(ROOT)/Finn/ViewController.swift"
	@PYTHON="$(PYTHON)" "$(ROOT)/scripts/check-baseline.sh"

lint: check

test: check

build: check
