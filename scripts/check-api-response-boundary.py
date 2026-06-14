#!/usr/bin/env python3
import sys
from pathlib import Path


source = Path(sys.argv[1]).read_text(encoding="utf-8")

required = [
    "let RestaurantAPIResponseMaxBytes = 1024 * 1024",
    "func acceptsRestaurantAPIResponse(response: NSURLResponse?, data: NSData?) -> Bool",
    "response as? NSHTTPURLResponse",
    "httpResponse.statusCode != 200",
    'response?.MIMEType?.lowercaseString != "application/json"',
    "responseData.length <= RestaurantAPIResponseMaxBytes",
    ".response {",
    "let data = responseObject as? NSData",
    "error != nil || !acceptsRestaurantAPIResponse(response, data: data)",
    "NSJSONSerialization.JSONObjectWithData(responseData",
]
for fragment in required:
    if fragment not in source:
        raise SystemExit("Restaurant API response boundary missing: " + fragment)

if ".responseJSON()" in source:
    raise SystemExit("Restaurant API responses must be validated before JSON parsing.")

callback_start = source.find(".response {")
callback_end = source.find("\n        }\n    }\n}", callback_start)
callback = source[callback_start:callback_end]
ordered = [
    "let data = responseObject as? NSData",
    "error != nil || !acceptsRestaurantAPIResponse(response, data: data)",
    "NSJSONSerialization.JSONObjectWithData(responseData",
]
positions = [callback.find(fragment) for fragment in ordered]
if -1 in positions or positions != sorted(positions):
    raise SystemExit("Transport and response bounds must run before restaurant JSON parsing.")


def accepts(status, mime_type, size):
    return (
        status == 200
        and mime_type is not None
        and mime_type.lower() == "application/json"
        and size is not None
        and size <= 1024 * 1024
    )


accepted = [
    (200, "application/json", 0),
    (200, "APPLICATION/JSON", 1024 * 1024),
]
rejected = [
    (None, "application/json", 1),
    (201, "application/json", 1),
    (204, "application/json", 0),
    (302, "application/json", 1),
    (400, "application/json", 1),
    (500, "application/json", 1),
    (200, None, 1),
    (200, "text/html", 1),
    (200, "application/json", None),
    (200, "application/json", 1024 * 1024 + 1),
]
if not all(accepts(*case) for case in accepted):
    raise SystemExit("Valid restaurant API response boundaries must remain accepted.")
if any(accepts(*case) for case in rejected):
    raise SystemExit("Invalid restaurant API response boundaries must fail closed.")

print("Restaurant API response boundary checks passed (12 cases).")
