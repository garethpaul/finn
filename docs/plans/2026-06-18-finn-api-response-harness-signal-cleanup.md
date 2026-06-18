---
title: Finn API Response Harness Signal Cleanup
type: reliability
date: 2026-06-18
status: planned
execution: code
---

# Finn API Response Harness Signal Cleanup

## Status: Planned

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

## Verification Plan

- Run `sh -n` on the runner and baseline gate.
- Run all Make gates from the repository and `make check` from an external
  directory.
- Exercise success, compiler-failure, and `TERM` cleanup paths with bounded
  fake compilers.
- Mutate the direct cleanup call and a signal binding and prove the baseline
  rejects both changes.
- Commit and push the implementation before recording exact-head hosted
  evidence and changing this plan to completed.
