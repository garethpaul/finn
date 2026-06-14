# AGENTS.md

## Repository purpose

`garethpaul/finn` is a legacy Swift iOS restaurant discovery sample that uses Core Location, a locally configured HTTPS API, Alamofire, CocoaPods, and swipeable restaurant cards.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `Podfile` - CocoaPods dependency definition
- `Finn.xcodeproj` - Xcode project
- `Finn.xcworkspace` - Xcode workspace
- `Finn` - repository source or sample assets
- `FinnTests` - repository source or sample assets

## Development commands

- Install dependencies: `pod install`
- Full baseline: `make check`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Local Apple development: `open Finn.xcworkspace`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Swift (11), C/C++ headers (2).
- Use the CocoaPods workspace when present; update `Podfile.lock` only with an intentional dependency change.
- Preserve legacy Xcode project settings and signing assumptions unless the change is explicitly about modernization.

## Testing guidance

- `FinnTests/FinnTests.swift` contains only template assertions; do not treat it as meaningful API, location, image-loading, or card-state coverage. The maintained regression gate is `make check`.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- `FINN_API_BASE_URL` is the local build setting used to configure the restaurant API endpoint.
- Keep private endpoints, API credentials, signing files, and local `.xcconfig` files out of source control.
- Avoid logging location data, restaurant preferences, or private API response payloads.
- Start location updates only after an authorized Core Location state, use the delegate-provided callback location, stop updates after the first usable fix or failure, and keep failure logs free of raw Core Location details.
- Coordinate parameters must be non-blank, parse completely as finite numbers, and remain within latitude and longitude ranges before restaurant API requests.
- `FINN_API_BASE_URL` must resolve to HTTPS with a host and no userinfo, query, fragment, or unresolved build-setting placeholder.
- Restaurant image URLs must use HTTPS with a host and no embedded userinfo before requests are created.
- Restaurant image redirects are rejected before redirected requests start.
- Restaurant API JSON parsing requires HTTP 200, `application/json`, and a body no larger than 1 MiB.
- Restaurant image responses must enforce the 5 MiB limit against declared and
  cumulative bytes before UIKit decoding, use a finite timeout, and clear
  request state without logging transport details.
- Trim and reject blank restaurant names or image URLs before cards are created, and keep picker rendering tolerant of missing restaurant state.
- Hosted macOS CI proves the checked-in Xcode project parses and static contracts pass; it does not prove CocoaPods installation, signing, location authorization, live API behavior, or image rendering.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
