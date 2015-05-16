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
    let url = ""
    
    func getRestaurant(lat: String, lon: String, completion: (result: Array<Restaurant>) -> Void){
        var new_result = Array<Restaurant>()
        Alamofire.request(.GET, url, parameters: ["lat": lat, "lon": lon]).responseJSON() {
            (_, _, JSON, _) in

            if let json = JSON as? Dictionary<String, AnyObject> {
                if let restaurants = json["data"] as? [[String : AnyObject]] {
                    for r in restaurants {
                        let name = r["name"]! as! String
                        let image = r["image"]! as! String
                        new_result.append(Restaurant(name: name, image: image))
                    }
                    
                    
                }
            }
            completion(result: new_result)

        }
        
    }
}
