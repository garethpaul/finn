---
title: Picker Restaurant State Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

`FinnPickerView` stored its restaurant as optional state but force-unwrapped it
while loading the image URL and rendering the name label. The main card queue
now guards too-short API responses, but keeping force unwraps in the card view
left a local crash path during future UI initialization or modernization work.

## Goals

- Remove restaurant force unwraps from picker image and label rendering.
- Preserve the existing card initializer and image loading behavior.
- Keep HTTPS image loading and API field normalization guardrails unchanged.
- Extend the static baseline so picker rendering remains defensive.

## Implementation

- Wrapped image URL lookup in `if let restaurant = restaurant`.
- Initialized the name label with an empty string and filled it only when the
  restaurant is present.
- Extended README, VISION, CHANGES, and `scripts/check-baseline.sh`.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `make lint`
- `make test`
- `make build`
- `git diff --check`

Full workspace verification still requires a macOS/Xcode environment with the
legacy CocoaPods dependencies installed.
