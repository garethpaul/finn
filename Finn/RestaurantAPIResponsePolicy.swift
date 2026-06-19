import Foundation

let RestaurantAPIResponseMaxBytes = 1024 * 1024

private let normalizedRestaurantAPIMIMEType: (String) -> String = { MIMEType in
#if EXECUTABLE_POLICY_TESTS
    return MIMEType.components(separatedBy: ";")[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
#else
    return MIMEType.componentsSeparatedByString(";")[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
#endif
}

let acceptsRestaurantAPIResponseHeadersValues: (Int?, String?, Int64) -> Bool = {
    statusCode, MIMEType, expectedContentLength in

    if statusCode != 200 || expectedContentLength < -1 || expectedContentLength > Int64(RestaurantAPIResponseMaxBytes) {
        return false
    }

    if let MIMEType = MIMEType {
        return normalizedRestaurantAPIMIMEType(MIMEType) == "application/json"
    }

    return false
}

let canAppendRestaurantAPIBytes: (Int, Int) -> Bool = { currentLength, incomingLength in
    return currentLength >= 0 && incomingLength >= 0 &&
        incomingLength <= RestaurantAPIResponseMaxBytes &&
        currentLength <= RestaurantAPIResponseMaxBytes - incomingLength
}

let acceptsRestaurantAPIResponseValues: (Int?, String?, Int?) -> Bool = {
    statusCode, MIMEType, dataLength in

    if statusCode != 200 {
        return false
    }

    if let MIMEType = MIMEType {
#if EXECUTABLE_POLICY_TESTS
        let normalizedMIMEType = normalizedRestaurantAPIMIMEType(MIMEType)
#else
        let normalizedMIMEType = normalizedRestaurantAPIMIMEType(MIMEType)
#endif
        if normalizedMIMEType != "application/json" {
            return false
        }
    } else {
        return false
    }

    if let dataLength = dataLength {
        return dataLength >= 0 && dataLength <= RestaurantAPIResponseMaxBytes
    }

    return false
}
