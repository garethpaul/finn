//
//  API.swift
//  Finn
//
//  Created by Gareth Jones  on 5/15/15.
//  Copyright (c) 2015 garethpaul. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func getRestaurant(lat: String, lon: String, completion: (result: Array<Restaurant>) -> Void){
        var new_result = Array<Restaurant>()

        if let requestURL = configuredAPIURL() {
            Alamofire.request(.GET, requestURL, parameters: ["lat": lat, "lon": lon]).responseJSON() {
                (_, _, JSON, _) in

                if let json = JSON as? Dictionary<String, AnyObject> {
                    if let restaurants = json["data"] as? [[String : AnyObject]] {
                        for r in restaurants {
                            if let name = r["name"] as? String, image = r["image"] as? String {
                                new_result.append(Restaurant(name: name, image: image))
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
