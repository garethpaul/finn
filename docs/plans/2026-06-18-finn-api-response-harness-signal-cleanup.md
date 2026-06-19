---
title: Finn API Response Harness Signal Cleanup
type: reliability
date: 2026-06-18
status: completed
execution: code
---

# Finn API Response Harness Signal Cleanup

## Status: Completed

## Summary

Make the standalone restaurant API response-policy runner remove its temporary
build directory when interrupted while `swiftc` is still running.

## Baseline

The runner removes its build directory after success and compiler failure, but
its exit-only signal traps leave `finn-api-response-tests.*` behind after
`TERM` under the repository's POSIX `/bin/sh` execution path.

## Requirements

- Invoke cleanup directly from each signal handler before returning the
  conventional signal-derived status.
- Keep normal exit cleanup and existing compiler/test behavior unchanged.
- Add a mutation-sensitive static contract that rejects exit-only handlers.
- Verify success, compiler failure, and bounded termination with isolated fake
  compilers and temporary directories.

## Verification Completed

- `sh -n` passed for the runner and baseline gate.
- `make check`, `make lint`, `make test`, and `make build` passed from the
  repository, and absolute-Makefile `make check` passed from `/tmp`.
- Isolated fake compilers proved success cleanup, compiler-failure cleanup with
  status 42, and bounded `TERM` cleanup with no residual temporary directory.
- Mutations removing the direct cleanup call and restoring the exit-only
  `TERM` binding were rejected by the baseline gate.
- The existing image-redirect and 13-case restaurant response-policy checks
  remained green.
- Diff, executable-mode, worktree, generated-artifact, and high-confidence
  credential-pattern audits passed.
- The implementation was committed and pushed as
  `12144a7220b4f46b820bc29e474159f6271f4f9e`.
- Push run `27747221507` and pull-request run `27747225845` completed
  successfully on that exact head, including the hosted Swift harness and
  Xcode project checks. PR #12 remained open and mergeable, with zero open
  branch code-scanning or Dependabot alerts.
- Linux still cannot execute Swift, Xcode, CocoaPods, CoreLocation, provider
  requests, image rendering, or device UI; those platform boundaries remain
  outside this deterministic runner fix.
