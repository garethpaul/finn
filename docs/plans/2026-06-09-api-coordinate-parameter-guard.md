---
title: API Coordinate Parameter Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

`APIClient.getRestaurant` receives latitude and longitude strings from the
location flow. The view controller formats normal callback coordinates, but the
API client still accepted blank or whitespace-only coordinate parameters if the
method was reused directly.

## Goals

- Trim latitude and longitude parameters inside the API client.
- Skip restaurant API requests when either coordinate parameter is blank.
- Preserve the existing endpoint URL and restaurant field guardrails.
- Extend the static baseline and docs for the coordinate parameter boundary.

## Implementation

- Added `cleanLat` and `cleanLon` trimming before endpoint lookup.
- Completed with an empty result and returned before requests when either value
  is blank.
- Sent the trimmed coordinate values to Alamofire.
- Extended README, SECURITY, VISION, CHANGES, and `scripts/check-baseline.sh`.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full workspace verification still requires a macOS/Xcode environment with the
legacy CocoaPods dependencies installed.
