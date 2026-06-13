# Changes

## 2026-06-13

- Gated restaurant location updates on an already granted or callback-delivered
  Core Location authorization state.
- Rejected missing and non-image restaurant response MIME types before declared
  length acceptance or body buffering.
- Replaced whole-response image buffering with incremental delegate delivery,
  declared and cumulative 5 MiB limits, finite timeout, and terminal cleanup.
- Retained and cancelled each picker card's active loader while avoiding a
  strong image-callback cycle.
- Rejected empty and over-5-MiB restaurant image data before UIKit decoding.
- Added static ordering, limit, documentation, and completed-evidence contracts
  for the initial decode boundary.

## 2026-06-12

- Replaced the Finn target's machine-specific bridging-header paths with the
  tracked repository-relative `Finn/BridgeHeader.h` setting for Debug and
  Release builds.
- Extended the maintenance baseline and docs to reject developer home paths in
  the checked-in Xcode project.

## 2026-06-10

- Rejected nonnumeric and out-of-range latitude/longitude parameters before
  restaurant API requests.
- Added a bounded, least-privilege macOS GitHub Actions workflow for the Finn
  maintenance baseline.
- Disabled checkout credential persistence so later workflow steps cannot reuse
  the GitHub token.
- Hardened the maintenance baseline to reject duplicate or relocated checkout
  credential settings that could override the least-privilege workflow value.
- Switched hosted Xcode validation to the checked-in project so absent generated
  CocoaPods files do not cause false failures.
- Extended the checker and docs to enforce the hosted validation contract.

## 2026-06-09

- Parsed restaurant image URLs before loading and rejected missing hosts or
  embedded username/password.
- Trimmed restaurant lookup coordinate parameters and skipped API requests when
  latitude or longitude is blank.
- Guarded picker card rendering so restaurant names and images are read through
  optional bindings instead of force-unwrapped state.
- Used the latest delegate-provided location payload for restaurant lookups
  instead of reading manager location state.
- Required HTTPS for restaurant image downloads and removed swipe preference
  event console logs.
- Stopped location updates after the first usable fix or failure and replaced
  raw Core Location error logging with a generic diagnostic.
- Added a static baseline guard and plan for the location update boundary.
- Parsed the restaurant API endpoint and rejected missing hosts, userinfo,
  query strings, and fragments before sending coordinates.
- Trimmed restaurant names and image URLs from API responses and skipped blank
  fields before building cards.

## 2026-06-08

- Added a static `make check` baseline for CocoaPods, API configuration,
  location logging, and card queue guardrails.
- Moved the restaurant API endpoint behind the `FINN_API_BASE_URL` build setting.
- Avoided coordinate logging and unsafe card removals when the API returns too
  few restaurants.
- Required the configured restaurant API endpoint to use HTTPS before sending
  coordinate parameters.
- Guarded restaurant image URL creation and image decoding to avoid crashes on
  bad image data.
