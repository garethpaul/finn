---
title: Execute the restaurant API response policy
type: testing
date: 2026-06-16
status: completed
execution: code
---

# Execute the restaurant API response policy

## Goal

Compile and execute the deterministic status, MIME, and body-size decision used
before restaurant JSON parsing, without requiring Alamofire, credentials, a
live API, CocoaPods, or an Apple device.

## Requirements

- Keep one Foundation-only response policy in app production source and the
  Xcode app target.
- Preserve NSURLResponse extraction and pre-parse delegation in `API.swift`.
- Compile the production policy with a standalone Swift harness from every Make
  gate when `swiftc` is available.
- Preserve the two accepted and ten rejected cases from the independent Python
  oracle, including the exact 1 MiB boundary.
- Keep the template XCTest target explicitly excluded from behavioral evidence.

## Work Completed

- Extracted `RestaurantAPIResponsePolicy.swift` and added it to the app target.
- Added a standalone Swift harness and bounded temporary-build runner.
- Wired all Make aliases to execute the harness before the Python/static gate.
- Retargeted the Python oracle across production policy and API delegation, and
  added target-membership, runner, case, documentation, and evidence contracts.

## Verification Completed

- all four Make gates passed from the repository root.
- The absolute Makefile path passed from an external directory.
- The production policy mutation failed after weakening the status boundary.
- The API delegation mutation failed after bypassing the production policy.
- The Xcode target membership mutation failed after removing the policy source.
- The accepted response mutation failed after removing a valid boundary case.
- The rejected response mutation failed after removing an invalid case.
- The plan evidence mutation failed after removing completed verification text.
- Shell and Python syntax, project references, executable modes, diff checks,
  artifact scans, and changed-line credential-pattern scans passed.
- `swiftc` and Xcode are unavailable on this Linux host, so local gates verify
  deterministic source wiring and defer Swift execution to hosted macOS.
- The hosted pull-request check is recorded against the exact pushed head in
  the external engineering tracker.
