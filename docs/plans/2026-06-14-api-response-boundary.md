---
title: Restaurant API Response Boundary
type: security
date: 2026-06-14
status: completed
execution: code
---

# Restaurant API Response Boundary

## Summary

Validate restaurant API transport results before JSON parsing. Require HTTP
200, an `application/json` media type, a present response body no larger than
1 MiB, and successful Foundation JSON parsing before extracting restaurant
fields.

## Prioritized Engineering Tasks

1. Replace implicit `responseJSON` parsing with the pinned Alamofire raw
   response callback.
2. Reject transport errors, missing HTTP responses or bodies, non-200 status,
   non-JSON media types, and oversized bodies.
3. Parse accepted bytes with Foundation and preserve the existing restaurant
   field filtering and empty-result completion contract.
4. Add source-order, boundary-matrix, and documentation contracts.

## Requirements

- R1. Only HTTP 200 responses may reach JSON parsing.
- R2. Accepted responses must declare `application/json`, allowing parameters.
- R3. Accepted bodies must be present and at most 1 MiB.
- R4. Every rejection must complete once with an empty restaurant array and
  generic diagnostics only.
- R5. Coordinate, endpoint, restaurant-field, and image guards remain intact.

## Non-Goals

- Streaming cancellation inside retired Alamofire 1.2.2.
- Retrying requests or changing coordinate precision.
- Making live restaurant API requests during validation.

## Verification

- `sh -n scripts/check-baseline.sh`
- `python3 scripts/check-api-response-boundary.py Finn/API.swift` passed the
  12-case status, media-type, body-presence, and byte-limit matrix from both
  the repository root and `/tmp`.
- Six hostile mutations were rejected for the status code, byte limit,
  media-type comparison, inclusive limit, raw-response callback, and transport
  error gate.
- `make check`, `make lint`, `make test`, and `make build` passed from the
  repository root; the absolute-path `make check` gate also passed from
  `/tmp`.
