# Changes

## 2026-06-09

- Used the latest delegate-provided location payload for restaurant lookups
  instead of reading manager location state.
- Required HTTPS for restaurant image downloads and removed swipe preference
  event console logs.
- Stopped location updates after the first usable fix or failure and replaced
  raw Core Location error logging with a generic diagnostic.
- Added a static baseline guard and plan for the location update boundary.
- Parsed the restaurant API endpoint and rejected missing hosts, userinfo,
  query strings, and fragments before sending coordinates.

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
