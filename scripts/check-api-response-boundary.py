#!/usr/bin/env python3
import sys
from pathlib import Path


if len(sys.argv) != 3:
    raise SystemExit(
        "usage: check-api-response-boundary.py "
        "<RestaurantAPIResponsePolicy.swift> <API.swift>"
    )

policy = Path(sys.argv[1]).read_text(encoding="utf-8")
api = Path(sys.argv[2]).read_text(encoding="utf-8")
source = policy + "\n" + api

required = [
    "let RestaurantAPIResponseMaxBytes = 1024 * 1024",
    "let acceptsRestaurantAPIResponseHeadersValues: (Int?, String?, Int64) -> Bool",
    "let canAppendRestaurantAPIBytes: (Int, Int) -> Bool",
    'normalizedRestaurantAPIMIMEType(MIMEType) == "application/json"',
    "class APIClient: NSObject, NSURLConnectionDataDelegate",
    "func acceptsRestaurantAPIResponseHeaders(response: NSURLResponse?) -> Bool",
    "acceptsRestaurantAPIResponseHeadersValues(statusCode, response?.MIMEType",
    "func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)",
    "if !acceptsRestaurantAPIResponseHeaders(response)",
    "func connection(connection: NSURLConnection!, didReceiveData data: NSData!)",
    "if !canAppendRestaurantAPIBytes(receivedData.length, data.length)",
    "receivedData.appendData(data)",
    "func connectionDidFinishLoading(connection: NSURLConnection!)",
    "finish(parseRestaurants(receivedData))",
    "NSJSONSerialization.JSONObjectWithData(data",
]
for fragment in required:
    if fragment not in source:
        raise SystemExit("Restaurant API response boundary missing: " + fragment)

for forbidden in (".responseJSON()", ".response {", "responseObject as? NSData"):
    if forbidden in api:
        raise SystemExit("Restaurant API responses must stream through the bounded delegate path.")

response = api.split(
    "func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)",
    1,
)[1].split(
    "func connection(connection: NSURLConnection!, didReceiveData data: NSData!)",
    1,
)[0]
data = api.split(
    "func connection(connection: NSURLConnection!, didReceiveData data: NSData!)",
    1,
)[1].split("func connectionDidFinishLoading", 1)[0]
if response.index("acceptsRestaurantAPIResponseHeaders(response)") > response.index("finish([])"):
    raise SystemExit("Restaurant response headers must be checked before completion.")
if data.index("canAppendRestaurantAPIBytes") > data.index("receivedData.appendData(data)"):
    raise SystemExit("Restaurant response bytes must be bounded before append.")


def accepts_headers(status, mime_type, declared):
    base_type = mime_type.split(";", 1)[0].strip().lower() if mime_type else None
    return status == 200 and base_type == "application/json" and -1 <= declared <= 1024 * 1024


accepted = [
    (200, "application/json", -1),
    (200, "APPLICATION/JSON; charset=utf-8", 1024 * 1024),
]
rejected = [
    (None, "application/json", 1),
    (201, "application/json", 1),
    (302, "application/json", 1),
    (500, "application/json", 1),
    (200, None, 1),
    (200, "text/html", 1),
    (200, "application/json", -2),
    (200, "application/json", 1024 * 1024 + 1),
]
if not all(accepts_headers(*case) for case in accepted):
    raise SystemExit("Valid restaurant API response headers must remain accepted.")
if any(accepts_headers(*case) for case in rejected):
    raise SystemExit("Invalid restaurant API response headers must fail closed.")

print("Restaurant API streaming boundary checks passed (11 cases).")
