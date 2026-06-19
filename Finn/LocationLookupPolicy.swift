import Foundation

let RestaurantLocationMaxAge: Double = 30
let RestaurantLocationMaxAccuracy: Double = 1500

let acceptsRestaurantLocationValues: (Double, Double, Double, Double) -> Bool = {
    latitude, longitude, horizontalAccuracy, age in
    return latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180 &&
        horizontalAccuracy >= 0 && horizontalAccuracy <= RestaurantLocationMaxAccuracy &&
        age >= 0 && age <= RestaurantLocationMaxAge
}
