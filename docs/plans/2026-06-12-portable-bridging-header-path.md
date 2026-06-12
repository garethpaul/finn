---
title: Portable Bridging Header Path
date: 2026-06-12
status: completed
execution: xcode-project
---

## Context

The Finn target's Debug and Release build settings point
`SWIFT_OBJC_BRIDGING_HEADER` at
`/Users/gareth/tmp/finn/Finn/BridgeHeader.h`. The header is tracked at
`Finn/BridgeHeader.h`, so the machine-specific absolute path prevents Xcode
builds from finding it in other checkouts.

## Goals

- Use the tracked bridging header through a repository-relative Xcode setting.
- Apply the same setting to Debug and Release configurations.
- Reject machine-specific `/Users/...` paths in the checked-in project.
- Preserve the legacy Swift, CocoaPods, dependency, signing, and deployment
  settings outside this portability fix.

## Implementation

- Set both Finn target configurations to
  `SWIFT_OBJC_BRIDGING_HEADER = Finn/BridgeHeader.h`.
- Extend `scripts/check-baseline.sh` to require the tracked header, exactly two
  matching build settings, and no `/Users/` path in the project file.
- Update README, VISION, SECURITY, and CHANGES with the portable project
  contract and local Xcode verification limitation.

## Verification

- `sh -n scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
- Hosted macOS `xcodebuild -list` through GitHub Actions
