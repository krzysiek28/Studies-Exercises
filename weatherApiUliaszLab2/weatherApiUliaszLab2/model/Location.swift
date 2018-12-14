//
//  Location.swift
//  weatherApiUliaszLab2
//
//  Created by Krzysztof on 06/11/2018.
//  Copyright © 2018 Krzysztof. All rights reserved.
//

import Foundation

struct Location: Decodable {
    let title: String
//    let locationType: String
    let woeid: Int
//    let coordinate: String
    
    init(json: [String: Any]){
        title = json["title"] as? String ?? ""
//        locationType = json["location_type"] as? String ?? ""
        woeid = json["woeid"] as? Int ?? -1
//        coordinate = json["latt_long"] as? String ?? ""
    }
}
