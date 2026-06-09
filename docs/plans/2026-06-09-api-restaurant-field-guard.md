---
title: API Restaurant Field Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

`getRestaurant` parses restaurant names and image URLs from the API response.
Those fields were optional at the JSON-cast boundary, but whitespace-only values
could still create empty cards or invalid image requests.

## Goals

- Preserve the existing restaurant API response shape.
- Trim restaurant names and image URLs before creating `Restaurant` models.
- Skip API rows with blank names or blank image URLs.
- Keep endpoint, location, image-loading, and card-queue guardrails unchanged.

## Implementation

- Added `cleanName` and `cleanImage` trimming in `APIClient.getRestaurant`.
- Appended restaurants only when both normalized fields are non-empty.
- Extended `scripts/check-baseline.sh` to require field trimming and blank-value
  rejection.
- Added Makefile aliases for `lint`, `test`, and `build` to run the same static
  baseline.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full workspace verification still requires a macOS/Xcode environment with the
legacy CocoaPods dependencies installed.
