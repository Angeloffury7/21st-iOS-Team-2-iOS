//
//  Address.swift
//  Core
//
//  Created by Ari on 2023/01/24.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation

public struct Address: Codable {
    
    public let fullName: String
    public let x: String
    public let y: String
    public let firstName: String
    public let secondName: String
    public let thirdName: String
    
}

extension Address {
    
    public init?(_ dictionary: [String: Any]) {
        guard let fullName = dictionary["fullName"] as? String,
              let x = dictionary["x"] as? String,
              let y = dictionary["y"] as? String,
              let firstName = dictionary["firstName"] as? String,
              let secondName = dictionary["secondName"] as? String,
              let thirdName = dictionary["thirdName"] as? String else {
            return nil
        }
        self.fullName = fullName
        self.x = x
        self.y = y
        self.firstName = firstName
        self.secondName = secondName
        self.thirdName = thirdName
    }
    
    public func formatted() -> String {
        return [firstName, secondName, thirdName]
            .filter { $0.isEmpty == false }
            .joined(separator: ", ")
    }
}

extension Address: Equatable, Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
}
