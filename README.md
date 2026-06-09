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

The baseline verifies CocoaPods lockfile expectations, workspace guidance,
local API endpoint configuration, location data logging guardrails, and safe
card queue handling. It also verifies that location updates stop after a usable
callback location or failure and that location failures do not log raw error
details. The API endpoint guard parses `FINN_API_BASE_URL` and rejects missing
hosts, unresolved build-setting placeholders, userinfo, query strings, and
fragments before sending coordinates. API restaurant fields are trimmed, and
blank restaurant names or image URLs are skipped before card creation. The
`make lint`, `make test`, and `make build` aliases run the same static baseline
while this legacy sample has no narrower installed gates here. For functional
testing, use Xcode's test action or `xcodebuild test` with the appropriate
scheme and destination.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- `FINN_API_BASE_URL` is the local build setting used to configure the restaurant API endpoint.
- Keep private endpoints, API credentials, signing files, and local `.xcconfig` files out of source control.

## Security and Privacy Notes

- Review changes touching network requests, sockets, or service endpoints; examples from the scan include Finn/Info.plist, FinnTests/Info.plist, Podfile.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include Finn/Info.plist, Finn/ViewController.swift.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include Finn/API.swift, Finn/FinnPickerView.swift, Finn/Info.plist, Finn/Picture.swift, and 4 more.
- Avoid logging location data, restaurant preferences, or private API response payloads.
- Restaurant image URLs should be loaded over HTTPS only.
- Blank restaurant names or image URLs from the API should be rejected before
  cards are created.
- Keep location updates scoped to the active restaurant lookup and avoid raw
  Core Location error details in logs.
- Use the delegate-provided callback location for lookups instead of reading
  potentially stale manager state.

## Maintenance Notes

- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- Run `make check` before pushing changes that touch CocoaPods, API configuration, location handling, or card queue behavior.
- Keep the location update and callback payload plans in `docs/plans/` aligned
  with any changes to coordinate lookup behavior.
- See `docs/plans/2026-06-09-api-restaurant-field-guard.md` for restaurant API
  field normalization coverage.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
