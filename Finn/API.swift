//
//  API.swift
//  Finn
//
//  Created by Gareth Jones  on 5/15/15.
//  Copyright (c) 2015 garethpaul. All rights reserved.
//

import Foundation

class APIClient {

    class func fetchRestaurants(restaurantHandler: (Array<Restaurant>) -> ()) -> Void {
            // Used for demo purposes
            var new_result = Array<Restaurant>()
            new_result.append(Restaurant(name: "Tacolicious", image: "https://irs3.4sqi.net/img/general/width960/313179_qs1WC2QpRzn3pE7feVx_WZ7sc2qPWDcv1NUMo_bIU7Q.jpg"))
            new_result.append(Restaurant(name: "Velvet Cantina", image: "https://irs2.4sqi.net/img/general/width960/26204741_MN3UzOy5A4HjDTEDicOmA8MYEZ1tbXT8btj7LGgDEe8.jpg"))
            new_result.append(Restaurant(name: "Velvet Cantina", image: "https://irs2.4sqi.net/img/general/width960/26204741_MN3UzOy5A4HjDTEDicOmA8MYEZ1tbXT8btj7LGgDEe8.jpg"))
            new_result.append(Restaurant(name:"Beretta", image: "https://irs2.4sqi.net/img/general/width960/50320602_N7DPJ2Lgumfuookph1aUwP2YulLPVyaMYRUnSB1I_xE.jpg"))
            restaurantHandler(new_result)
    }
}
