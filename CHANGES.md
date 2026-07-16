# Changes

## 2026-07-16T00:00:00Z - P2 - Stop discarding executable policy suite failures

### Summary
The `check` recipe ran the two executable Swift policy suites and the hostile
mutation suite as a `;`-separated list inside a single `if` block. Make runs each
recipe line through one `sh -c` without `set -e`, so the list exited with the
status of only its last command and both policy suites' failures were discarded.
A failing suite reported success. Because CI runs on `macos-15`, where `swiftc`
is present, this affected the live gate rather than a dormant path.

### Work completed
- `&&`-joined the executable policy suites so any one failing fails the gate,
  matching the pattern already used by `foursquare-ar-camera-ios`.
- Added a baseline assertion pinning the `&&`-join, so reverting to `;` is
  caught rather than silently reintroducing the swallow.

### Threads
- None.

### Files changed
- `Makefile` — `&&`-join the executable policy suites.
- `scripts/check-baseline.sh` — assert the policy suites stay `&&`-joined.

### Validation
- Native Swift suites — not run; `swiftc` is unavailable on Linux, so their
  pass/fail behaviour on macOS is unverified here.
- In-repo reproduction with `SWIFTC=/bin/true`, so both policy suites genuinely
  fail (exit 127) — before: `make check` exited 0; after: exited 2.
- Isolated replica of the recipe shape — `;` with a passing last command exited
  0; `&&` exited 2.
- Baseline assertion liveness — reverting the recipe to `;` while keeping the
  assertion is caught with the intended message.
- `make check`, `make lint`, `make test`, `make build` on a clean tree — passed.

### Bugs / findings
- Only `test-finn-boundary-mutations.py`, as the last command in the list, was
  load-bearing; the two suites it complements were not.

## 2026-06-27T00:34:00Z - P1 - Reject IPv4-mapped image hosts

### Summary
Closed an image-request SSRF bypass where an IPv4 loopback or private address
encoded as an IPv4-mapped IPv6 literal avoided both existing host classifiers.

### Work completed
- Rejected `::ffff:` image hosts, including bracketed URL-host forms, before
  any image request is created.
- Added the mapped-loopback case to the production Swift policy harness and a
  Linux-runnable source contract.
- Added an eighth hostile mutation for removal of the mapped-address guard.
- Made Swift-only mutation execution skip with the other native tests when
  `swiftc` is unavailable instead of breaking the documented portable gate.

### Threads
- None; no open pull requests or issues existed, and stale branches were behind
  the protected default branch.

### Files changed
- `Finn/RemoteImagePolicy.swift` — reject IPv4-mapped IPv6 literals.
- `Tests/FinnBoundaryPolicyTests/main.swift` — add native mapped-loopback case.
- `scripts/test-finn-network-boundaries.py` — enforce the source and harness
  contract on non-Swift hosts.
- `scripts/test-finn-boundary-mutations.py` — reject mapped-guard removal.
- `Makefile` — run Swift mutations only when `swiftc` is available.
- `README.md`, `SECURITY.md` — document the mapped-address boundary.
- `docs/plans/2026-06-27-ipv4-mapped-image-hosts.md` — record design/evidence.

### Validation
- Native Swift harness — not run locally because `swiftc` is unavailable.
- Linux-runnable contract before implementation — failed on the missing
  mapped-address guard.
- Linux-runnable contract after implementation — passed.
- `make check` — passed fake-network, redirect, response, project, and baseline
  gates with a truthful native Swift skip.
- Python compilation, shell syntax, and `git diff --check` — passed.

### Bugs / findings
- `::ffff:127.0.0.1` contained colons but matched none of the loopback, ULA, or
  link-local prefixes, so the policy incorrectly treated it as a public host.
- The portable Make gate unconditionally invoked a Swift-only mutation runner
  after correctly skipping the other native tests.

### Blockers
- Local Linux cannot compile the Swift policy; hosted macOS is authoritative for
  the native harness and eight mutation cases.

### Next action
- Require the exact pull-request head to pass hosted Swift, Xcode project,
  mutation, and CodeQL checks before merge.

## 2026-06-19

- Replaced the fully buffered restaurant API callback with an owned streaming
  connection that rejects redirects, invalid status/media type, declared bodies
  over 1 MiB, and cumulative overflow before append.
- Rejected stale, future, invalid, and excessively inaccurate location fixes;
  stopped location and API work when the restaurant screen disappears; and
  ignored stale completions through request generations.
- Rejected localhost, private, link-local, multicast, and reserved IP image
  targets, limited image media types, and inspected dimensions before UIKit
  decoding to block compressed pixel bombs.
- Bounded parsed restaurant count and field lengths, retained two-decimal
  coordinate precision, and added native policy, fake-network, static, and
  seven hostile mutation checks.

## 2026-06-16

- Extracted the restaurant response status/MIME/size predicate into app
  production source and added a standalone Swift harness for all 13 boundaries.
- Extended the maintained baseline to require API delegation, app-target
  membership, harness wiring, and complete accepted/rejected case coverage.
- The static gate requires GNU Make, a POSIX shell, and Python 3. Added an
  explicit interpreter override, actionable runtime diagnostics, and mandatory
  plist parsing after the shared preflight.

## 2026-06-14

- Required HTTP 200, `application/json`, and at most 1 MiB before restaurant API JSON parsing.
- Restaurant image redirects are rejected before redirected requests can bypass
  the validated URL boundary.

## 2026-06-13

- Made static verification independent of the caller's working directory by
  resolving the baseline checker from the loaded Makefile.
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
