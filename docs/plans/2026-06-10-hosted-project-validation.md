# Hosted Project Validation

status: completed

## Context

Finn had a comprehensive local static baseline, but no hosted workflow ran it.
The checked-in workspace references a generated CocoaPods project that is not
committed, so credential-free validation should parse `Finn.xcodeproj` rather
than fail on the intentionally absent `Pods/Pods.xcodeproj`.

## Changes

- Added a least-privilege macOS GitHub Actions workflow that runs `make check`.
- Pinned checkout by commit, bounded the job with a timeout, and cancel
  superseded runs.
- Changed the installed-Xcode check to list the checked-in Finn project; local
  functional development still uses the workspace after `pod install`.
- Extended the baseline and project documentation to enforce this CI contract.

## Verification

- `make check`
- Workflow YAML parse
- Hosted `macos-15` GitHub Actions run
