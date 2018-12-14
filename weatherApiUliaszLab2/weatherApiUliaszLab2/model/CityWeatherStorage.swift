//
//  CityWeatherStorage.swift
//  weatherApiUliaszLab2
//
//  Created by Krzysztof on 30/10/2018.
//  Copyright © 2018 Krzysztof. All rights reserved.
//

import Foundation

class CityWeatherStorage {
    static let shared: CityWeatherStorage = CityWeatherStorage()
    
    var objects: [WeatherDetails]
    
    private init(){
        objects = [WeatherDetails]()
        objects.append(WeatherDetails(city: "44418", cityName: "London"))
        objects.append(WeatherDetails(city: "523920", cityName: "Warsaw"))
        objects.append(WeatherDetails(city: "1118370", cityName: "Tokyo"))
    }
}
