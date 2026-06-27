# IPv4-Mapped Image Hosts

status: completed

## Context

The image policy rejected dotted IPv4 loopback/private ranges and several IPv6
local prefixes independently. An IPv4 address embedded in the IPv4-mapped IPv6
range, such as `::ffff:127.0.0.1`, matched neither classifier and was accepted
as a provider-controlled HTTPS image host.

## Design

Reject the standardized `::ffff:` mapped prefix before broader IPv6 handling.
Also recognize the bracketed spelling that may appear at URL-host boundaries.
Rejecting the mapped range wholesale is safer than duplicating the IPv4 parser
inside a legacy Swift 1-compatible policy and avoids alternate local-address
representations reaching `NSURLConnection`.

The production Swift harness owns behavior. The Python fake-network contract
requires both the guard and the mapped-loopback test so Linux verification can
fail closed when the native compiler is unavailable.

## Verification

- The Python contract failed before implementation with `IPv4-mapped IPv6 image
  hosts must be rejected`.
- The Python contract and full portable `make check` passed after implementation.
- Python compilation, shell syntax, and `git diff --check` passed.
- Local native Swift execution was skipped because `swiftc` is unavailable;
  hosted macOS must execute the production harness and eight hostile mutations.

## Scope

This closes literal IPv4-mapped IPv6 targets. DNS rebinding and resolution-time
address changes remain outside the syntactic URL policy.
