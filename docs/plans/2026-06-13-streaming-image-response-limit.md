---
title: Streaming Image Response Limit
type: security
status: completed
date: 2026-06-13
---

# Streaming Image Response Limit

## Summary

Replace the whole-response image convenience request with a legacy-compatible
delegate flow that rejects oversized declared or cumulative response bodies
before the complete remote payload is buffered or passed to UIKit.

## Priority

1. Enforce the existing 5 MiB boundary while image bytes arrive.
2. Cancel oversized, failed, or abandoned requests and release buffered state.
3. Preserve the reviewed URL, malformed-image, privacy, and callback behavior.
4. Keep the change compatible with the repository's historical Swift and iOS
   scope instead of introducing a broad networking migration.

## Requirements

- R1. `Picture` must use an `NSURLConnectionDataDelegate` flow rather than
  `sendAsynchronousRequest` so bytes can be inspected incrementally.
- R2. A positive `expectedContentLength` over 5 MiB must cancel the connection
  before response bytes are appended.
- R3. Unknown or inaccurate lengths must remain bounded by rejecting any chunk
  that would make the accumulated data exceed 5 MiB.
- R4. Empty or oversized data must never reach `UIImage(data:)`; valid image
  data may be decoded only after the connection finishes.
- R5. Success, failure, explicit cancellation, and oversized-response paths
  must clear the connection, handler, and accumulated bytes without logging
  URLs, payloads, response metadata, or error details.
- R6. The request must have a finite timeout, and the picker must retain the
  loader for the active card while avoiding a strong callback cycle.
- R7. Static contracts must reject convenience-response buffering, limit drift,
  missing header or cumulative guards, decode-before-finish ordering, missing
  cleanup, and loss of caller retention.
- R8. Documentation must replace the known whole-response limitation with the
  actual streaming boundary and keep platform validation claims truthful.

## Non-Goals

- Migrating the app to `NSURLSession`, modern Swift, Swift Package Manager, or
  a current image-loading framework.
- Changing the restaurant API, Alamofire request flow, card queue, image
  resizing, cache behavior, or accepted image formats.
- Adding retries, persistence, background transfers, or user-visible errors.
- Claiming compilation, signing, simulator/device execution, or live image
  rendering from this Linux host.

## Implementation Units

### 1. Incremental Image Loader

Files: `Finn/Picture.swift`

- Make the loader an `NSObject` data delegate with retained request state.
- Reject oversized declared lengths and cumulative chunks before appending.
- Decode only after successful completion and clear state on every terminal
  path.

### 2. Picker Lifetime

Files: `Finn/FinnPickerView.swift`

- Retain one loader for the active card.
- Use a weak callback capture and cancel the request when the picker is
  released.

### 3. Static Contracts

Files: `scripts/check-baseline.sh`

- Require the exact streaming, limit, ordering, cleanup, timeout, retention,
  and no-logging contracts.
- Require completed mutation and hosted-verification evidence in this plan.

### 4. Repository Guidance

Files: `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`, `AGENTS.md`

- Record the transport-level response boundary and legacy validation limits.

## Verification Plan

- Run `make check`, `make lint`, `make test`, and `make build`.
- Restore `sendAsynchronousRequest`, remove the declared-length guard, remove
  the cumulative guard, move decode before completion, remove cleanup, and
  remove picker retention; the static gate must reject each mutation.
- Run shell syntax, plist/XML parsing, executable-mode verification,
  `git diff --check`, and intended-file secret scans.
- Take bounded exact-head pull-request, workflow, and code-scanning snapshots
  after push; do not start a watch loop.

## Work Completed

- Replaced the whole-response convenience request with an
  `NSURLConnectionDataDelegate` loader that receives incremental chunks.
- Added one 5 MiB boundary for both declared response length and cumulative
  data, including unknown or inaccurate content lengths.
- Added a 15-second request timeout, active-connection identity checks, and
  cleanup of the connection, callback, and accumulated bytes on every terminal
  path.
- Retained one loader per picker card, cancelled it when the card is released,
  and used a weak image callback capture.
- Extended the static baseline with streaming, ordering, cleanup, lifetime,
  documentation, and completed-plan contracts.
- Updated contributor, security, maintenance, vision, and change guidance with
  the transport-level boundary.

## Verification Completed

- `make check`, `make lint`, `make test`, and `make build` passed against the
  final implementation.
- The convenience-buffering mutation failed with `Image transport must enforce
  the streaming 5 MiB boundary without logging remote content.`
- The declared-length mutation failed with the same streaming-boundary error.
- The cumulative-limit mutation failed with the same streaming-boundary error.
- The decode-completion mutation failed with `Image decoding and callbacks must
  occur only after bounded completion.`
- The cleanup mutation failed with `Every terminal image path must clear
  connection, handler, and bytes.`
- The picker-retention mutation failed with the streaming-boundary error.
- A timeout-drift mutation also failed with the streaming-boundary error.
- `xcodebuild` project listing was skipped because `xcodebuild` is not installed
  on this Linux host; compilation, signing, simulator/device execution, and live
  image rendering are not claimed.
- The hosted pull-request check is not available before the implementation
  push; bounded exact-head evidence will be recorded in the engineering tracker
  without a watch loop.
