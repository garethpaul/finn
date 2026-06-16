# Python Verification Preflight

## Status: In Progress

## Context

The maintenance checker depends on Python for redirect, API-response, plist,
source-order, and completed-plan contracts. It invokes `python3` unconditionally
before and after a branch that claims the plist parse can be skipped when
Python is absent. The result is a misleading skip message followed by a generic
command failure, and contributors cannot select another compatible Python 3
executable.

## Prioritized Engineering Tasks

1. Make the maintenance gate's Python 3 dependency explicit, configurable, and
   fail-fast with actionable diagnostics.
2. Investigate restaurant API redirect policy with authoritative Alamofire and
   Apple runtime evidence before changing request behavior.
3. Validate current Xcode and CocoaPods compatibility on an Apple toolchain and
   modernize only from observed build failures.

This plan implements item 1 because it affects every offline verification run
and is fully testable on the current host.

## Objectives

- Define one Make-level Python command with a `python3` default.
- Pass the selected command into the checker while preserving location-
  independent Make behavior.
- Fail before any Python-backed check when the command is missing or is not
  Python 3.
- Remove the contradictory optional plist-parse branch and route all eight
  Python invocations through the preflighted command.
- Document GNU Make, a POSIX shell, and Python 3 as static-gate prerequisites,
  including the supported command override.
- Add static and behavioral contracts for propagation, preflight behavior,
  invocation ownership, documentation, and completed evidence.

## Scope

- Update `Makefile`, `scripts/check-baseline.sh`, `README.md`, `AGENTS.md`,
  `VISION.md`, and `CHANGES.md`.
- Extend the maintained baseline and this plan's completion evidence.
- Do not change Swift source, CocoaPods files, Xcode metadata, API or image
  behavior, hosted permissions, or platform support claims.

## Verification

- Run POSIX shell syntax validation.
- Run all four Make aliases from the repository root.
- Run `make check` from an external working directory.
- Run the gate with an explicit compatible Python command override.
- Prove missing and non-Python-3 commands fail with intended diagnostics.
- Reject isolated hostile mutations covering propagation, preflight behavior,
  the removed skip path, invocation routing, documentation, and plan evidence.
- Audit exact paths, generated artifacts, credential-like values, dependency
  drift, conflict markers, file modes, and whitespace.

## Runtime Boundary

The change is an offline static-gate improvement. Xcode, simulator, devices,
location authorization, live restaurant requests, image rendering, card
interaction, and external endpoint behavior are not executed or claimed.
