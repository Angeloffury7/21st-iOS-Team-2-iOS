//
//  ProfileCoordinatorInterface.swift
//  Profile
//
//  Created by 임영선 on 2022/12/15.
//  Copyright © 2022 Fitfty. All rights reserved.
//
import Common

public protocol ProfileCoordinatorInterface: AnyObject {
    
    func showPost(profileType: ProfileType, boardToken: String)
    func showReport(reportedToken: String)
    func showMyFitfty(_ myFitftyType: MyFitftyType)
    func switchMainTab()
    func showSetting()
    func dismiss()
    func finished()
    func finishedTapGesture()
}
