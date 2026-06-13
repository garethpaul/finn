---
title: Image Decode Payload Limit
type: security
status: in_progress
date: 2026-06-13
---

# Image Decode Payload Limit

## Summary

Reject oversized restaurant image data before UIKit decoding so remote content
cannot send an unbounded byte buffer into `UIImage` processing.

## Priority

1. Keep oversized response data out of image decoding.
2. Preserve current HTTPS, host, userinfo, error, and malformed-image guards.
3. Describe the legacy transport limitation truthfully.

## Requirements

- R1. `Picture` must define one explicit 5 MiB maximum image byte count.
- R2. The completion handler must reject empty or oversized `NSData` before
  calling `UIImage(data:)`.
- R3. Valid in-range images must retain the existing callback behavior.
- R4. The guard must not log URLs, image bytes, response metadata, or errors.
- R5. Static count and ordering contracts must prevent limit drift or moving
  decoding ahead of validation.
- R6. Documentation must state that the legacy convenience API still buffers
  the response before the decode guard runs.

## Non-Goals

- Replacing `NSURLConnection`, Alamofire, CocoaPods, or the historical Swift
  toolchain.
- Claiming a streaming transport cap, cancellation after response headers, or
  full memory-bounded downloading.
- Changing image resizing, card rendering, API response parsing, or URL policy.
- Claiming simulator, device, signing, or live service validation on Linux.

## Implementation Units

### 1. Decode Boundary

Files: `Finn/Picture.swift`

- Add one 5 MiB byte constant.
- Reject zero-length and oversized data before `UIImage` initialization.

### 2. Static Contracts

Files: `scripts/check-baseline.sh`

- Require the exact constant, range guard, and guard-before-decode ordering.
- Require completed mutation and hosted-verification evidence in this plan.

### 3. Repository Guidance

Files: `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Record the decode boundary and the remaining whole-response buffering risk.

## Verification Plan

- Run `make check`, `make lint`, `make test`, and `make build`.
- Remove the size guard, drift the limit, and move decode before validation;
  the static gate must reject each mutation.
- Run shell syntax, plist/XML parsing, `git diff --check`, and intended-file
  secret scans.
- Take one bounded exact-head pull-request and CodeQL snapshot after push; do
  not poll.
