# Image Response Media-Type Boundary

status: completed

## Context

Restaurant image downloads enforce HTTPS, timeout, declared length, cumulative
bytes, and bounded decode, but do not reject a missing or non-image MIME type at
response time. HTML and text responses should fail closed before buffering.

## Requirements

- R1. Require a non-empty response MIME type beginning with `image/`, compared
  case-insensitively.
- R2. Validate the MIME type after active-connection validation and response
  buffer reset, but before declared-length acceptance or data delivery.
- R3. Cancel and clear state for missing or non-image MIME types without logging
  response headers, URLs, bodies, or errors.
- R4. Preserve HTTPS/userinfo, timeout, 5 MiB declared and cumulative limits,
  terminal cleanup, bounded UIKit decode, weak picker callback, and cancellation.
- R5. Add section-scoped ordering, exact-contract, docs, and completed-plan checks.

## Verification Plan

- Run all four Make gates, shell syntax, plist/XML parsing, and `git diff --check`.
- Reject missing, permissive, reordered, non-cancelling, docs, status, and
  evidence mutations in isolated copies.
- Inspect exact intended paths, protected project/dependency files, generated
  artifacts, and added secret-like values.
- Use no restaurant API, image endpoint, credentials, signing, simulator, or
  device runtime during local verification.

## Non-Goals

- Sniffing file signatures or changing the 5 MiB limit.
- Changing request headers, redirects, URL policy, image decoding, or UI state.
- Modernizing Swift, UIKit, NSURLConnection, CocoaPods, or Xcode metadata.

## Work Completed

- Added a nil-safe, case-insensitive `image/` MIME helper.
- Rejected missing and non-image response types after resetting prior bytes and
  before declared-length handling or delegate data delivery.
- Preserved cancellation, terminal cleanup, response-size, decode, and picker
  ownership contracts.
- Added section-scoped ordering, exact helper, docs, and plan-evidence checks.

## Verification Completed

- All four Make gates passed the maintained static baseline; `xcodebuild was unavailable` on Linux, so no current-Xcode compile or runtime result is claimed.
- App and test plists plus workspace/storyboard XML parsed successfully; shell
  syntax and `git diff --check` passed.
- Eight isolated hostile mutations were rejected: helper removal, permissive
  media prefix, missing-type acceptance, check-after-length ordering,
  non-cancelling rejection, missing docs, stale status, and missing evidence.
- Exact intended paths, protected project/dependency files, generated artifacts,
  and added secret-like values were inspected without findings.
- No restaurant API, image endpoint, credential, signing, simulator, device,
  or user data was used.
