//
//  MainCoordinatorInterface.swift
//  MainFeed
//
//  Created by Ari on 2022/12/05.
//  Copyright © 2022 Fitfty. All rights reserved.
//

import Foundation
import Common

public protocol MainCoordinatorInterface: AnyObject {
    
    func showSettingAddress()
    
    func showProfile(profileType: ProfileType, nickname: String)
    
    func showPost(profileType: ProfileType, userToken: String, boardToken: String)

    func showWeatherInfo()
    
    func showWelcomeSheet()
    
}
