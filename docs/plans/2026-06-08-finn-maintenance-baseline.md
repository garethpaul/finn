# Finn Maintenance Baseline

date: 2026-06-08
status: completed

## Context

Finn is a legacy Swift iOS app for restaurant discovery with CocoaPods,
Alamofire, MDCSwipeToChoose, location access, and a card-style UI. The priority
is to keep the sample recoverable without committing private API endpoints or
leaking location data.

## Completed Scope

- Added `scripts/check-baseline.sh` and `make check` for repeatable static
  verification.
- Documented that developers should open `Finn.xcworkspace` after `pod install`.
- Moved the restaurant API endpoint to the `FINN_API_BASE_URL` build setting via
  `FinnAPIBaseURL` instead of an empty hardcoded URL, and require HTTPS before
  sending coordinates.
- Guarded the API client against missing endpoints and malformed restaurant
  records.
- Removed rounded latitude/longitude logging and guarded card setup against
  too-small restaurant result sets.
- Ignored local environment and Xcode configuration files that may contain API
  endpoints, credentials, or signing settings.

## Verification

- `make check`

## Follow-Ups

- Run `xcodebuild test` or Xcode's test action on a macOS machine with the
  legacy CocoaPods toolchain installed.
- Add focused XCTest coverage around API parsing and card queue behavior after a
  Swift modernization pass.
- Update dependencies only in a dedicated migration with lockfile changes.
