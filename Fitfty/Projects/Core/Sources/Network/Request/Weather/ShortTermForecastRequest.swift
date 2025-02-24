//
//  DailyWeatherRequest.swift
//  Core
//
//  Created by Ari on 2023/01/17.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation

struct ShortTermForecastRequest: Codable {
    
    let numOfRows: Int
    let pageNo: Int
    let baseDate: String
    let baseTime: String
    let nx: Int
    let ny: Int
    
    enum CodingKeys: String, CodingKey {
        case numOfRows, pageNo, nx, ny
        case baseDate = "base_date"
        case baseTime = "base_time"
    }
    
}
