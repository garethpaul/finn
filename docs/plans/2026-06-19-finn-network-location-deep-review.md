# Finn network and location deep review

status: completed

## Scope

Review PRs #3-#12 as one linear maintenance stack, then trace the Core Location,
restaurant API, JSON parsing, image transport, UIKit decoding, and card ownership
paths. Preserve the legacy Swift/iOS behavior while failing closed at privacy,
transport, memory, and asynchronous ownership boundaries.

## Findings and provenance

1. The 1 MiB restaurant response check ran only after Alamofire buffered the
   complete body. The limit protected JSON parsing, not transport memory.
2. Core Location accepted stale, future, invalid-accuracy, and excessively
   inaccurate fixes, and a lookup could finish after the screen stopped owning it.
3. Provider-controlled image hosts could target literal local/private addresses.
   Bounded compressed bytes also did not bound decoded pixel memory.
4. A stale API redirect callback could reset a newer request unless connection
   identity was checked before terminal state mutation.

The buffering and lifecycle behavior originated in the 2015 client and was
carried forward by the remediation stack. PRs #4-#12 added useful decode,
streaming-image, authorization, redirect, and response policies but did not close
these adjacent ownership boundaries.

## Fix

- Own restaurant API transport with `NSURLConnectionDataDelegate`, reject
  redirects, validate headers before buffering, and cap every append at 1 MiB.
- Validate location age, range, and accuracy; retain and cancel the API client;
  and gate main-queue UI mutation with a lookup generation. Keep two-decimal
  coordinate precision.
- Reject local/private literal image hosts, allow only JPEG/PNG/GIF responses,
  and inspect metadata before UIKit decoding with 4096-per-axis and 16 Mi-pixel
  limits.
- Bound accepted restaurant count and field lengths before card creation.

## Evidence

- Native Swift policy tests cover location, host, media type, dimensions, API
  headers, and streamed append limits.
- Fake-network tests cover valid chunked delivery, cumulative overflow, invalid
  status/media/length, redirect ownership, cancellation, and decode ordering.
- Eight hostile mutations reject weakened age, host, mapped-address, dimension,
  append, connection-identity, decode, and lifecycle controls.
- `make check`, all Make aliases, external-directory execution, project parsing,
  shell/Python syntax checks, and hosted checks are required.

## Residual risk

No live restaurant provider, Core Location session, CocoaPods build, simulator,
or physical device was used. Syntactic host checks do not prevent DNS rebinding.
The iOS 8 / Swift 1-era dependency stack remains archival and should not be
treated as a supported production client.
