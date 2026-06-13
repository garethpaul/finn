---
title: Location-Independent iOS Verification
type: reliability
date: 2026-06-13
status: planned
execution: code
---

# Location-Independent iOS Verification

## Summary

Resolve the maintained static checker from the loaded Makefile so every gate
works when Make is invoked outside the checkout.

## Requirements

- R1. Derive the repository root from `MAKEFILE_LIST`.
- R2. Invoke `scripts/check-baseline.sh` through its repository-rooted path.
- R3. Add a static contract that rejects caller-directory-relative invocation.
- R4. Preserve all Swift, Xcode, workspace, CocoaPods, location, API, image,
  privacy, and hosted-validation contracts.
- R5. Record actual root and external-directory verification before completion.

## Verification Plan

- Run `make check`, `make lint`, `make test`, and `make build` at repository
  root.
- Run the full gate from `/tmp` through the absolute Makefile path.
- Reject isolated hostile root-derivation, checker-path, documentation, plan
  status, and verification-evidence mutations.
- Run shell syntax, plist/XML parsing, `git diff --check`, exact-path review,
  secret/signing inspection, and generated-artifact inspection.

## Non-Goals

- Changing iOS runtime behavior, dependencies, project settings, signing, or
  API configuration.
- Claiming Xcode build, simulator, device, location, API, or image execution.

## Work Completed

Pending implementation.

## Verification Completed

Pending implementation and verification.
