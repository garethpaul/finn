# finn

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/finn` is an Apple platform application or Objective-C/Swift sample. App for finding Restaurants/Food etc

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Swift (11), C/C++ headers (2).

## Repository Contents

- `README.md` - project overview and local usage notes
- `CHANGES.md` - concise history of maintenance changes
- `Makefile` - local verification entry point
- `Podfile` - Apple platform dependency metadata
- `Finn` - source or example code
- `Finn.xcodeproj` - Xcode project file
- `Finn.xcworkspace` - CocoaPods workspace to open after dependency install
- `FinnTests` - source or example code
- `Podfile.lock` - Apple platform dependency metadata
- `SECURITY.md` - security reporting and disclosure guidance
- `scripts/check-baseline.sh` - static checks for API config, lockfile, location logging, and card queue guardrails
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: Finn, FinnTests
- Dependency and build manifests: Podfile, Podfile.lock
- Entry points or build surfaces: Finn.xcworkspace, Finn.xcodeproj
- Test-looking files: FinnTests/FinnTests.swift, FinnTests/Info.plist

## Getting Started

### Prerequisites

- Git
- macOS with Xcode for building Apple platform projects
- CocoaPods if dependencies need to be installed

### Setup

```bash
git clone https://github.com/garethpaul/finn.git
cd finn
pod install
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Open `Finn.xcworkspace` in Xcode after `pod install`, choose the app or sample scheme, and run it on the matching simulator/device.
- Configure the restaurant API endpoint locally with the `FINN_API_BASE_URL`
  build setting. Use an HTTPS URL with a host and no embedded username/password,
  query string, or fragment because coordinates are sent as request parameters.
  Do not commit private endpoints or API credentials.

## Testing and Verification

Run the static baseline:

```bash
make check
```

Use the absolute Makefile path to run the same gate from another working
directory. Verification resolves the checker relative to the loaded Makefile
rather than the caller's directory.

The baseline verifies CocoaPods lockfile expectations, workspace guidance,
local API endpoint configuration, location data logging guardrails, and safe
card queue handling. It also verifies that location updates start only after
when-in-use or always authorization is granted, stop after a usable callback
location or failure, and do not log raw error details. The API endpoint guard
parses `FINN_API_BASE_URL` and rejects missing
hosts, unresolved build-setting placeholders, userinfo, query strings, and
fragments before sending coordinates. Coordinate parameters are trimmed,
parsed completely, and checked against latitude/longitude ranges before
requests. API restaurant fields are trimmed,
and blank restaurant names or image URLs are skipped before card creation.
Picker views avoid force-unwrapping restaurant state while rendering names and
images.
Restaurant image downloads inspect parsed URL parts, require HTTPS with a host,
and reject embedded username/password before creating image requests.
Image downloads use incremental `NSURLConnection` delegate callbacks, reject a
declared or cumulative response over 5 MiB before UIKit decoding, and use a
15-second request timeout. Picker cards retain the active loader, cancel it when
released, and avoid a strong image-callback cycle.
Missing or non-image response MIME types are cancelled before declared-length
acceptance or body buffering.
The `make lint`, `make test`, and `make build` aliases run the same static
baseline while this legacy sample has no narrower installed gates here. For
functional testing, use Xcode's test action or `xcodebuild test` with the
appropriate scheme and destination.
GitHub Actions runs `make check` on macOS for pushes and pull requests. Hosted
validation uses read-only permissions without persisted checkout credentials
and parses the checked-in `Finn.xcodeproj`; developers should continue to open
`Finn.xcworkspace` after `pod install` for dependency-backed builds.
The Finn target uses the tracked `Finn/BridgeHeader.h` through a
repository-relative Xcode setting in both Debug and Release configurations, so
the project does not depend on another developer's home-directory path.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- `FINN_API_BASE_URL` is the local build setting used to configure the restaurant API endpoint.
- Keep private endpoints, API credentials, signing files, and local `.xcconfig` files out of source control.
- Keep Xcode file references repository-relative; do not commit paths under a
  developer home directory.

## Security and Privacy Notes

- Review changes touching network requests, sockets, or service endpoints; examples from the scan include Finn/Info.plist, FinnTests/Info.plist, Podfile.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include Finn/Info.plist, Finn/ViewController.swift.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include Finn/API.swift, Finn/FinnPickerView.swift, Finn/Info.plist, Finn/Picture.swift, and 4 more.
- Avoid logging location data, restaurant preferences, or private API response payloads.
- Blank coordinate parameters should be rejected before restaurant API
  requests.
- Restaurant image URLs should be loaded over HTTPS only.
- Restaurant image URLs should include a host and no embedded username/password.
- Restaurant image responses should enforce the 5 MiB limit while bytes arrive,
  not only after a complete response has been buffered.
- Restaurant image redirects are rejected before a redirected request can load.
- Blank restaurant names or image URLs from the API should be rejected before
  cards are created.
- Picker views should not force-unwrap restaurant state when rendering names or
  images.
- Keep location updates scoped to the active restaurant lookup and avoid raw
  Core Location error details in logs.
- Start location updates only after Core Location reports an authorized state;
  requesting when-in-use permission is asynchronous and must not trigger an
  eager lookup.
- Use the delegate-provided callback location for lookups instead of reading
  potentially stale manager state.

## Maintenance Notes

- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- Run `make check` before pushing changes that touch CocoaPods, API configuration, location handling, or card queue behavior.
- Keep `.github/workflows/check.yml` aligned with the local maintenance
  baseline.
- See `docs/plans/2026-06-10-hosted-project-validation.md` for the hosted Xcode
  project validation boundary.
- Keep the location update and callback payload plans in `docs/plans/` aligned
  with any changes to coordinate lookup behavior.
- See `docs/plans/2026-06-09-api-restaurant-field-guard.md` for restaurant API
  field normalization coverage.
- See `docs/plans/2026-06-09-api-coordinate-parameter-guard.md` for restaurant
  lookup coordinate parameter coverage.
- See `docs/plans/2026-06-09-image-url-parts-guard.md` for parsed restaurant
  image URL validation.
- See `docs/plans/2026-06-13-streaming-image-response-limit.md` for the
  transport-level image body boundary.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
