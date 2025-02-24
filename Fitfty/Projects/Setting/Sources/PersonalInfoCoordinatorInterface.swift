//
//  PersonalInfoCoordinatorInterface.swift
//  Profile
//
//  Created by Ari on 2023/01/28.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation

public protocol PersonalInfoCoordinatorInterface: AnyObject {
    func showAuthView()
    func pushWithdrawView()
    func pushWithdrawConfirmView()
    func finished()
    func pop()
}
