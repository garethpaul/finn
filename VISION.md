## Finn Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Finn is a Swift iOS app for finding restaurants and food, with a swipe-oriented
UI and network-backed restaurant data.

The repository is useful as a legacy iOS sample combining CocoaPods, Alamofire,
and card-style restaurant selection. Basic context lives in [`README.md`](README.md).

The goal is to keep the app recoverable and understandable while making API,
location, and credential boundaries explicit.

The current focus is:

Priority:

- Preserve the restaurant model, swipe UI, and network API flow
- Keep CocoaPods setup and workspace expectations visible
- Avoid committing API keys, private endpoints, signing material, or location data
- Keep old Swift/iOS assumptions clear

Current baseline:

- `scripts/check-baseline.sh` and `make check` verify the CocoaPods lockfile,
  workspace guidance, API configuration, and location guardrails.
- `FINN_API_BASE_URL` feeds the `FinnAPIBaseURL` Info.plist key so private API
  endpoints stay in local HTTPS build settings.
- API endpoint validation parses the configured URL and rejects unresolved
  placeholders, missing hosts, embedded userinfo, query strings, and fragments.
- Rounded location coordinates are not logged from the view controller.
- Location updates stop after a usable foreground fix or failure, and failure
  logs avoid raw Core Location error details.
- Restaurant lookups use the delegate-provided callback location instead of
  reading potentially stale manager state.
- Card queue setup guards against API responses with too few restaurants.
- Restaurant names and image URLs from the API are trimmed and blank values are
  skipped before card creation.
- Picker views avoid force-unwrapping restaurant state while rendering card
  names and images.
- Restaurant image downloads require HTTPS and swipe preferences are not logged.

Next priorities:

- Verify the app with Xcode after `pod install` on a machine with the legacy toolchain
- Add XCTest coverage around API parsing and card queue behavior
- Modernize Swift, Alamofire, MDCSwipeToChoose, and iOS target in a dedicated pass
- Add tests or manual checklists for restaurant loading and card interactions
- Preserve the one-shot foreground location lookup boundary when modernizing
  Core Location handling
- Keep callback-location handling covered when changing the location delegate
- Keep picker rendering tolerant of missing restaurant state during legacy UI
  modernization

Contribution rules:

- One PR = one focused API, UI, build, or documentation change.
- Open the workspace and verify app behavior after `pod install`.
- Keep credentials and signing files out of git.
- Document any external API or location behavior change.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Restaurant discovery can involve location and preference data. Do not add
analytics, tracking, or hidden network calls without explicit documentation and
user control.

API credentials and private endpoints must remain out of source control.

## What We Will Not Merge (For Now)

- Hardcoded real API credentials or private endpoints
- Background location tracking
- Broad Swift migrations bundled with feature changes
- Generated signing material or local paths

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
