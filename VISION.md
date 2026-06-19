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
- The static gate requires GNU Make, a POSIX shell, and Python 3. Its
  interpreter command is explicit and fails fast when missing or incompatible.
- GitHub Actions runs that baseline on macOS and parses the checked-in Xcode
  project without requiring generated CocoaPods files, private API settings, or
  persisted checkout credentials.
- Debug and Release use the tracked `Finn/BridgeHeader.h` through the same
  repository-relative build setting.
- `FINN_API_BASE_URL` feeds the `FinnAPIBaseURL` Info.plist key so private API
  endpoints stay in local HTTPS build settings.
- API endpoint validation parses the configured URL and rejects unresolved
  placeholders, missing hosts, embedded userinfo, query strings, and fragments.
- Restaurant lookup coordinate parameters are parsed completely and checked
  against valid latitude and longitude ranges before requests.
- Location updates begin only after Core Location reports an authorized state;
  the asynchronous when-in-use prompt never triggers an eager lookup.
- Rounded location coordinates are not logged from the view controller.
- Location updates stop after a usable foreground fix or failure, and failure
  logs avoid raw Core Location error details.
- Restaurant lookups use the delegate-provided callback location instead of
  reading potentially stale manager state.
- Card queue setup guards against API responses with too few restaurants.
- Restaurant names and image URLs from the API are trimmed and blank values are
  skipped before card creation.
- Restaurant image redirects are rejected before any redirected request starts.
- Picker views avoid force-unwrapping restaurant state while rendering card
  names and images.
- Restaurant image downloads require HTTPS and swipe preferences are not logged.
- Restaurant image downloads also require a parsed host and reject embedded
  username/password before requests.
- Restaurant image loading rejects declared or cumulative payloads over 5 MiB
  during delegate delivery, before UIKit processing, with a finite timeout and
  explicit request-state cleanup.
- Restaurant image responses require an `image/` MIME type before declared
  length acceptance or body buffering.
- Restaurant API JSON parsing requires HTTP 200, `application/json`, and a body
  no larger than 1 MiB. The transport enforces the limit while bytes stream;
  redirects and cumulative overflow fail before parsing.
- The response-boundary predicate is shared by the app target and an executable
  standalone Swift behavioral harness.
- Location fixes must be fresh, finite, in range, and reasonably accurate;
  pending lookups are cancelled when the screen disappears and stale callbacks
  cannot mutate the card stack.
- Restaurant image targets reject local/private literal hosts, and raster
  dimensions are inspected before UIKit decoding to reduce SSRF and pixel-bomb
  risk.

Next priorities:

- Verify the app with Xcode after `pod install` on a machine with the legacy toolchain
- Add XCTest coverage around API parsing and card queue behavior
- Modernize Swift, Alamofire, MDCSwipeToChoose, and iOS target in a dedicated pass
- Add tests or manual checklists for restaurant loading and card interactions
- Preserve the one-shot foreground location lookup boundary when modernizing
  Core Location handling
- Keep callback-location handling covered when changing the location delegate
- Keep coordinate parameter trimming covered when changing restaurant API calls
- Keep picker rendering tolerant of missing restaurant state during legacy UI
  modernization
- Keep parsed image URL validation covered when changing restaurant card image
  loading
- Keep the 5 MiB declared and cumulative image-response boundaries covered when
  changing image transport
- Preserve the 1 MiB streaming API boundary and request-generation ownership.
- Preserve the image-host and decoded-dimension policies when replacing the
  legacy transport.
- Keep hosted project validation aligned with `make check`.
- Keep Xcode project file references portable across checkout locations.

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
