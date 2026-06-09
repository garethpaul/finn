---
title: API Endpoint URL Parts
date: 2026-06-09
status: completed
execution: code
---

## Context

`FINN_API_BASE_URL` is intentionally local configuration because restaurant
lookups send location coordinates as request parameters. The existing guard
required an HTTPS string prefix, but it did not parse the URL or reject missing
hosts, embedded username/password userinfo, query strings, or fragments.

## Goals

- Parse the configured API endpoint before sending coordinates.
- Require HTTPS with a non-empty host.
- Reject unresolved build-setting placeholders, embedded userinfo, query
  strings, and fragments.
- Keep restaurant parsing and location callback guardrails unchanged.

## Implementation

- Added `configuredAPIURL()` to trim and validate the `FinnAPIBaseURL` value.
- Updated `getRestaurant` to return an empty result when endpoint validation
  fails.
- Extended README, VISION, CHANGES, and the static baseline with the endpoint
  URL-parts contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode workspace listing is still skipped locally because `xcodebuild` is
not installed in this environment.
