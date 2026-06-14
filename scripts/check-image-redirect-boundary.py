#!/usr/bin/env python3
import sys
from pathlib import Path


source = Path(sys.argv[1]).read_text(encoding="utf-8")
plan = Path(sys.argv[2]).read_text(encoding="utf-8")

signature = (
    "func connection(connection: NSURLConnection!, willSendRequest request: "
    "NSURLRequest!, redirectResponse response: NSURLResponse!) -> NSURLRequest!"
)
required = [
    signature,
    "if !isActiveConnection(connection)",
    "if response != nil",
    "connection.cancel()",
    "resetState()",
    "return nil",
    "return request",
]
for fragment in required:
    if fragment not in source:
        raise SystemExit("Image redirect boundary missing: " + fragment)

start = source.find(signature)
end = source.find(
    "func connection(connection: NSURLConnection!, didReceiveResponse", start
)
callback = source[start:end]
ordered = [
    "if !isActiveConnection(connection)",
    "if response != nil",
    "connection.cancel()",
    "resetState()",
    "return nil",
    "return request",
]
positions = []
offset = 0
for fragment in ordered:
    position = callback.find(fragment, offset)
    positions.append(position)
    if position != -1:
        offset = position + len(fragment)
if -1 in positions:
    raise SystemExit(
        "Redirect handling must reject inactive/redirected requests before returning the initial request."
    )
if callback.count("return nil") != 2:
    raise SystemExit("Inactive and redirected image requests must each return nil.")


def forwarded(active, redirect_response):
    if not active:
        return False
    if redirect_response:
        return False
    return True


if not forwarded(True, False):
    raise SystemExit("The initial active image request must remain allowed.")
if forwarded(False, False) or forwarded(True, True) or forwarded(False, True):
    raise SystemExit("Inactive or redirected image requests must fail closed.")

for evidence in ("status: completed", "hostile mutations were rejected", "make check"):
    if evidence not in plan:
        raise SystemExit("Image redirect plan missing: " + evidence)

print("Image redirect boundary checks passed.")
