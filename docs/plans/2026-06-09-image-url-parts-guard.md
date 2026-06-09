---
title: Image URL Parts Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

Restaurant image loading already required URL strings to start with
`https://`, but a raw prefix check does not validate the parsed URL shape. Image
requests should require an HTTPS scheme, a real host, and no embedded
username/password before transport starts.

## Goals

- Preserve HTTPS-only restaurant image loading.
- Reject image URLs without a host.
- Reject image URLs with embedded userinfo.
- Keep the legacy picker image flow otherwise unchanged.
- Extend the static baseline and docs for the parsed-image-URL boundary.

## Implementation

- Replaced the raw `absoluteString` prefix check in `Picture.get` with parsed
  `scheme`, `host`, `user`, and `password` checks.
- Updated README, SECURITY, VISION, CHANGES, and `scripts/check-baseline.sh`.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

XcodeBuildMCP simulator testing was unavailable in this Codex session, and the
local environment does not provide `xcodebuild`.
