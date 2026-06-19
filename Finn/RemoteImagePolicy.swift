import Foundation

let RestaurantImageMaxDimension = 4096
let RestaurantImageMaxPixels = 4096 * 4096
let RestaurantImageMaxDataBytes = 5 * 1024 * 1024

private let normalizedPolicyString: (String) -> String = { value in
#if EXECUTABLE_POLICY_TESTS
    return value.lowercased()
#else
    return value.lowercaseString
#endif
}

private let policyInteger: (String) -> Int? = { value in
#if EXECUTABLE_POLICY_TESTS
    return Int(value)
#else
    return value.toInt()
#endif
}

private let policyHostComponents: (String) -> [String] = { value in
#if EXECUTABLE_POLICY_TESTS
    return value.components(separatedBy: ".")
#else
    return value.componentsSeparatedByString(".")
#endif
}

private let policyContainsColon: (String) -> Bool = { value in
#if EXECUTABLE_POLICY_TESTS
    return value.contains(":")
#else
    return value.rangeOfString(":") != nil
#endif
}

let isAllowedRestaurantImageHost: (String) -> Bool = { host in
    let normalizedHost = normalizedPolicyString(host)
    if normalizedHost.isEmpty || normalizedHost == "localhost" || normalizedHost.hasSuffix(".localhost") {
        return false
    }

    if policyContainsColon(normalizedHost) {
        if normalizedHost == "::1" || normalizedHost.hasPrefix("fc") ||
            normalizedHost.hasPrefix("fd") || normalizedHost.hasPrefix("fe8") ||
            normalizedHost.hasPrefix("fe9") || normalizedHost.hasPrefix("fea") ||
            normalizedHost.hasPrefix("feb") {
            return false
        }
    }

    let octets = policyHostComponents(normalizedHost)
    if octets.count == 4 {
        var values = [Int]()
        var validIPv4 = true
        for octet in octets {
            if let value = policyInteger(octet) {
                if value < 0 || value > 255 {
                    return false
                }
                values.append(value)
            } else {
                validIPv4 = false
                break
            }
        }

        if validIPv4 && values.count == 4 {
            let first = values[0]
            let second = values[1]
            if first == 0 || first == 10 || first == 127 ||
                (first == 169 && second == 254) ||
                (first == 172 && second >= 16 && second <= 31) ||
                (first == 192 && second == 168) || first >= 224 {
                return false
            }
        }
    }

    return true
}

func isAllowedRestaurantImageURL(url: NSURL) -> Bool {
    if url.scheme != "https" || url.user != nil || url.password != nil || url.fragment != nil {
        return false
    }

    if let host = url.host {
        return isAllowedRestaurantImageHost(host)
    }

    return false
}

let acceptsRestaurantImageMetadataValues: (String?, Int, Int) -> Bool = {
    MIMEType, width, height in
    if width <= 0 || height <= 0 || width > RestaurantImageMaxDimension || height > RestaurantImageMaxDimension {
        return false
    }

    if width > RestaurantImageMaxPixels / height {
        return false
    }

    if let MIMEType = MIMEType {
        let normalizedMIMEType = normalizedPolicyString(MIMEType)
        return normalizedMIMEType == "image/jpeg" || normalizedMIMEType == "image/png" ||
            normalizedMIMEType == "image/gif"
    }

    return false
}

let acceptsRestaurantImageResponseValues: (Int?, String?, Int64) -> Bool = {
    statusCode, MIMEType, expectedContentLength in
    return statusCode == 200 &&
        expectedContentLength >= -1 && expectedContentLength <= Int64(RestaurantImageMaxDataBytes) &&
        acceptsRestaurantImageMetadataValues(MIMEType, 1, 1)
}
