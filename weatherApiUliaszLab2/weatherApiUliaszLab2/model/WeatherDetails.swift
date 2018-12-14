//
//  WeatherDetails.swift
//  weatherApiUliaszLab2
//
//  Created by Krzysztof on 30/10/2018.
//  Copyright © 2018 Krzysztof. All rights reserved.
//

import Foundation

struct Weather: Decodable {
    let id: Int
    let weather_state_name: String
    let weather_state_abbr: String
    let wind_direction_compass: String
    let created: String
    let applicable_date: String
    let min_temp: Double
    let max_temp: Double
    let the_temp: Double
    let wind_speed: Double
    let wind_direction: Double
    let air_pressure: Double
    let humidity: Int
    //    let visibility: Double
    let predictability: Int

    init(json: [String: Any]){
        id = json["id"] as? Int ?? -1
        weather_state_name = json["weather_state_name"] as? String ?? ""
        weather_state_abbr = json["weather_state_abbr"] as? String ?? ""
        wind_direction_compass = json["wind_direction_compass"] as? String ?? ""
        created = json["created"] as? String ?? ""
        applicable_date = json["applicable_date"] as? String ?? ""
        min_temp = json["min_temp"] as? Double ?? -1
        max_temp = json["max_temp"] as? Double ?? -1
        the_temp = json["the_temp"] as? Double ?? -1
        wind_speed = json["wind_speed"] as? Double ?? -1
        wind_direction = json["wind_direction"] as? Double ?? -1
        air_pressure = json["air_pressure"] as? Double ?? -1
        humidity = json["humidity"] as? Int ?? -1
        //        visibility = json["visibility"] as? Double ?? -1
        predictability = json["predictability"] as? Int ?? -1
    }
}

class WeatherDetails {
    
    let baseURL = "https://www.metaweather.com/api/location/"
    var url : String  {
        get {
            return "\(baseURL)\(city)/\((getCurrentDate()))"
        }
    }
    
    var weather = [Weather]()
    
    //basic parametr to extract json
    var city:String
    var cityName:String
    
    init(city:String, cityName:String) {
        self.city = city
        self.cityName = cityName
    }
    
    func initValues(){
        self.getWeatherFromURL(self.url)
    }

    func getWeatherFromURL(_ url:String){
        let strURL = URL(string: url)
        let urlSession = URLSession.shared
        
        if let myUrl = strURL {
            let dataTask = urlSession.dataTask(with: myUrl, completionHandler: {
                (data, urlResponse, error) in
                
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    if let jsonData = data {
                        do {
                            let weatherData = try JSONDecoder().decode([Weather].self, from: jsonData)
                            for element in weatherData{
                                self.weather.append(element)
                            }
                        } catch let err {
                            print("error2: \(err)")
                        }
                    }
                    
                    OperationQueue.main.addOperation({
                    })
                }
            })
            
            dataTask.resume()
        }
    }

    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        return formatter.string(from: date)
    }
}
