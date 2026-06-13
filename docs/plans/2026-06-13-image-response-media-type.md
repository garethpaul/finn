# Image Response Media-Type Boundary

status: planned

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
