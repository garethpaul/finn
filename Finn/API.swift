//
//  API.swift
//  Finn
//
//  Created by Gareth Jones  on 5/15/15.
//  Copyright (c) 2015 garethpaul. All rights reserved.
//

import Foundation
import Alamofire

let RestaurantAPIResponseMaxBytes = 1024 * 1024

func acceptsRestaurantAPIResponse(response: NSURLResponse?, data: NSData?) -> Bool {
    if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode != 200 {
            return false
        }
    } else {
        return false
    }

    if response?.MIMEType?.lowercaseString != "application/json" {
        return false
    }

    if let responseData = data {
        return responseData.length <= RestaurantAPIResponseMaxBytes
    }

    return false
}

class APIClient {
    
    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>
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
        var parsedValue: Double = 0

        if !scanner.scanDouble(&parsedValue) || !scanner.atEnd {
            return false
        }

        return parsedValue >= minimum && parsedValue <= maximum
    }
    
    func getRestaurant(lat: String, lon: String, completion: (result: Array<Restaurant>) -> Void){
        var new_result = Array<Restaurant>()
        let cleanLat = lat.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let cleanLon = lon.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if !coordinateInRange(cleanLat, minimum: -90, maximum: 90) ||
            !coordinateInRange(cleanLon, minimum: -180, maximum: 180) {
            completion(result: new_result)
            return
        }

        if let requestURL = configuredAPIURL() {
            Alamofire.request(.GET, requestURL, parameters: ["lat": cleanLat, "lon": cleanLon]).response {
                (_, response, responseObject, error) in

                let data = responseObject as? NSData

                if error != nil || !acceptsRestaurantAPIResponse(response, data: data) {
                    completion(result: new_result)
                    return
                }

                var jsonError: NSError?
                var JSON: AnyObject?
                if let responseData = data {
                    JSON = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: &jsonError)
                }

                if jsonError != nil {
                    completion(result: new_result)
                    return
                }

                if let json = JSON as? Dictionary<String, AnyObject> {
                    if let restaurants = json["data"] as? [[String : AnyObject]] {
                        for r in restaurants {
                            if let name = r["name"] as? String, image = r["image"] as? String {
                                let cleanName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                                let cleanImage = image.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                                if !cleanName.isEmpty && !cleanImage.isEmpty {
                                    new_result.append(Restaurant(name: cleanName, image: cleanImage))
                                }
                            }
                        }
                    }
                }
                completion(result: new_result)

            }
        } else {
            completion(result: new_result)
        }
        
    }
}
