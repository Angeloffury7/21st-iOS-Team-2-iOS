//
//  MyFitftyRequest.swift
//  Core
//
//  Created by 임영선 on 2023/02/11.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation

public struct MyFitftyRequest: Codable {
    public let filePath: String
    public let content: String
    public let temperature: String?
    public let location: String?
    public let cloudType: String?
    public let photoTakenTime: String?
    public let tagGroup: TagGroup
    
    public init(filePath: String, content: String, temperature: String?, location: String?, cloudType: String?, photoTakenTime: String?, tagGroup: TagGroup) {
        self.filePath = filePath
        self.content = content
        self.temperature = temperature
        self.location = location
        self.cloudType = cloudType
        self.photoTakenTime = photoTakenTime
        self.tagGroup = tagGroup
    }
    
}

public struct TagGroup: Codable {
    public let weather: String
    public let style: [String]
    public let gender: String
    
    public init(weather: String, style: [String], gender: String) {
        self.weather = weather
        self.style = style
        self.gender = gender
    }
    
}
