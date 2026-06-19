//
//  API.swift
//  Finn
//
//  Created by Gareth Jones  on 5/15/15.
//  Copyright (c) 2015 garethpaul. All rights reserved.
//

import Foundation

func acceptsRestaurantAPIResponseHeaders(response: NSURLResponse?) -> Bool {
    var statusCode: Int?
    if let httpResponse = response as? NSHTTPURLResponse {
        statusCode = httpResponse.statusCode
    }

    return acceptsRestaurantAPIResponseHeadersValues(statusCode, response?.MIMEType, response?.expectedContentLength ?? -2)
}

class APIClient: NSObject, NSURLConnectionDataDelegate {
    private let maximumRestaurants = 100
    private let maximumRestaurantNameCharacters = 200
    private let maximumImageURLCharacters = 2048
    private var activeConnection: NSURLConnection?
    private var receivedData = NSMutableData()
    private var completionHandler: ((result: Array<Restaurant>) -> Void)?

    var url: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("FinnAPIBaseURL") as? String ?? ""
    }

    func configuredAPIURL() -> String? {
        let configuredURL = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if configuredURL.isEmpty || configuredURL.hasPrefix("$(") {
            return nil
        }

        if let endpointURL = NSURL(string: configuredURL) {
            if endpointURL.scheme == "https" &&
                endpointURL.user == nil &&
                endpointURL.password == nil &&
                endpointURL.query == nil &&
                endpointURL.fragment == nil {
                if let host = endpointURL.host {
                    if !host.isEmpty {
                        return configuredURL
                    }
                }
            }
        }

        return nil
    }

    func coordinateInRange(value: String, minimum: Double, maximum: Double) -> Bool {
        let scanner = NSScanner(string: value)
        scanner.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        var parsedValue: Double = 0

        if !scanner.scanDouble(&parsedValue) || !scanner.atEnd {
            return false
        }

        return parsedValue >= minimum && parsedValue <= maximum
    }

    func getRestaurant(lat: String, lon: String, completion: (result: Array<Restaurant>) -> Void) {
        cancel()

        let cleanLat = lat.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let cleanLon = lon.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if !coordinateInRange(cleanLat, minimum: -90, maximum: 90) ||
            !coordinateInRange(cleanLon, minimum: -180, maximum: 180) {
            completion(result: [])
            return
        }

        if let requestURL = configuredAPIURL(), components = NSURLComponents(string: requestURL) {
            components.queryItems = [
                NSURLQueryItem(name: "lat", value: cleanLat),
                NSURLQueryItem(name: "lon", value: cleanLon),
            ]

            if let URL = components.URL {
                let request = NSMutableURLRequest(URL: URL)
                request.timeoutInterval = 15
                receivedData = NSMutableData()
                completionHandler = completion
                if let connection = NSURLConnection(request: request, delegate: self, startImmediately: false) {
                    activeConnection = connection
                    connection.start()
                    return
                }
            }
        }

        completion(result: [])
    }

    func cancel() {
        activeConnection?.cancel()
        resetState()
    }

    func connection(connection: NSURLConnection!, willSendRequest request: NSURLRequest!, redirectResponse response: NSURLResponse!) -> NSURLRequest! {
        if !isActiveConnection(connection) {
            return nil
        }

        if response != nil {
            connection.cancel()
            finish([])
            return nil
        }

        return request
    }

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        if !isActiveConnection(connection) {
            return
        }

        receivedData.length = 0
        if !acceptsRestaurantAPIResponseHeaders(response) {
            connection.cancel()
            finish([])
        }
    }

    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        if !isActiveConnection(connection) {
            return
        }

        if !canAppendRestaurantAPIBytes(receivedData.length, data.length) {
            connection.cancel()
            finish([])
            return
        }

        receivedData.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if isActiveConnection(connection) {
            finish(parseRestaurants(receivedData))
        }
    }

    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        if isActiveConnection(connection) {
            finish([])
        }
    }

    private func parseRestaurants(data: NSData) -> Array<Restaurant> {
        var result = Array<Restaurant>()
        var jsonError: NSError?
        let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
        if jsonError != nil {
            return result
        }

        if let json = JSON as? Dictionary<String, AnyObject>, restaurants = json["data"] as? [[String: AnyObject]] {
            for restaurant in restaurants {
                if result.count >= maximumRestaurants {
                    break
                }

                if let name = restaurant["name"] as? String, image = restaurant["image"] as? String {
                    let cleanName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let cleanImage = image.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if count(cleanName) <= maximumRestaurantNameCharacters && count(cleanImage) <= maximumImageURLCharacters,
                        let imageURL = NSURL(string: cleanImage) where !cleanName.isEmpty && !cleanImage.isEmpty && isAllowedRestaurantImageURL(imageURL) {
                        result.append(Restaurant(name: cleanName, image: cleanImage))
                    }
                }
            }
        }

        return result
    }

    private func finish(result: Array<Restaurant>) {
        let handler = completionHandler
        resetState()
        if let handler = handler {
            dispatch_async(dispatch_get_main_queue()) {
                handler(result: result)
            }
        }
    }

    private func isActiveConnection(connection: NSURLConnection) -> Bool {
        if let currentConnection = activeConnection {
            return connection === currentConnection
        }

        return false
    }

    private func resetState() {
        activeConnection = nil
        completionHandler = nil
        receivedData.length = 0
    }

    deinit {
        cancel()
    }
}
