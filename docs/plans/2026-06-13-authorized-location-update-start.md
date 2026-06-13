---
title: Authorized Location Update Start
type: privacy
date: 2026-06-13
status: completed
execution: code
---

# Authorized Location Update Start

## Summary

Start restaurant location updates only after when-in-use authorization is
already granted or arrives through the location-manager callback.

## Problem

`viewDidLoad` requests when-in-use permission and immediately starts updates
whenever location services are enabled. The authorization request is
asynchronous, so the sample attempts location collection before the user has
granted the requested scope.

## Requirements

- R1. Configure the manager delegate and desired accuracy without collecting.
- R2. Request only when-in-use authorization.
- R3. Start updates from `viewDidLoad` only when status is authorized.
- R4. Start updates when the authorization callback reports an authorized state.
- R5. Stop updates for denied, restricted, or other non-authorized states.
- R6. Preserve callback location validation, one-shot stop, coordinate bounds,
  API request behavior, card guards, image transport, and generic logs.
- R7. Add ordering, uniqueness, documentation, completion, and mutation contracts.
- R8. Do not claim signed-device authorization or live location/API execution.

## Verification Plan

- Run the focused authorization lifecycle source contract.
- Run `make check`, `make lint`, `make test`, and `make build`.
- Reject mutations that restore eager start, remove callback start/stop, stale
  the plan, or remove evidence.
- Audit exact paths, artifacts, credentials/signing, and unchanged project,
  workflow, dependencies, plist, API, and image-loader surfaces.

## Non-Goals

- Changing requested accuracy, location retention, API coordinates, or cards.
- Modernizing the legacy Swift/Core Location API surface.

## Verification Completed

- The focused source and documentation contracts passed in an isolated copy,
  and six hostile mutations were rejected: eager initial start, missing callback
  start, missing callback stop, loss of when-in-use authorization, stale plan
  status, and missing verification evidence.
- `make check`, `make lint`, `make test`, and `make build` passed against the
  completed implementation and plan record.
- `xcodebuild was unavailable` on this Linux host, so no signed application or
  simulator build was attempted.
- No live location authorization, restaurant API request, image load, or card
  interaction was performed.
