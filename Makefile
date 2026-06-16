.PHONY: build check lint test

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3

check:
	@PYTHON="$(PYTHON)" "$(ROOT)/scripts/check-baseline.sh"

lint: check

test: check

build: check
