---
title: Restaurant Image Redirect Rejection
type: security
status: completed
date: 2026-06-14
---

# Restaurant Image Redirect Rejection

## Summary

Reject redirected restaurant image requests so an initially validated HTTPS URL
cannot move the legacy loader to an unvalidated destination before existing
media-type, byte-limit, and decode guards run.

## Prioritized Engineering Tasks

1. Add the `NSURLConnection` redirect delegate callback.
2. Allow only the initial active request and reject every redirect response.
3. Cancel and clear connection state before returning `nil` for redirects.
4. Add source-order, synthetic behavior, and synchronized documentation checks.

## Requirements

- R1. The initial active request must continue unchanged.
- R2. Redirected and inactive requests must return `nil`.
- R3. Redirect rejection must cancel the connection and clear buffered state.
- R4. Existing HTTPS URL, media type, byte limit, timeout, and image decode
  boundaries must remain unchanged.
- R5. Static contracts must prove callback ordering and redirect behavior.

## Non-Goals

- Following redirects to a separately allowlisted host.
- Replacing `NSURLConnection` or modernizing the legacy Swift toolchain.
- Claiming live image-server, simulator, or signed-device validation from Linux.

## Verification

- The focused callback model allowed the initial active request and rejected
  inactive requests plus redirect callbacks.
- Seven hostile mutations were rejected across the delegate signature, active
  connection guard, redirect test, cancellation, cleanup, nil return, and
  completed-plan evidence.
- `make check`, `make lint`, `make test`, and `make build` passed the portable
  maintenance baseline from the repository root and `make check` passed through
  the absolute Makefile path from an external working directory.
- Local Xcode compilation, simulator execution, signed-device testing, live API
  lookup, and image-server behavior were not run because this Linux host lacks
  the historical Apple toolchain, signing identity, and private API settings.
- Exact intended-path, generated-artifact, whitespace, conflict-marker,
  project-file preservation, and changed-line credential-pattern audits passed.
