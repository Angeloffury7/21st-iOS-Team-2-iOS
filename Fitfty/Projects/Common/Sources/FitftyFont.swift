//
//  FitftyFont.swift
//  Common
//
//  Created by Watcha-Ethan on 2022/12/04.
//  Copyright © 2022 Fitfty. All rights reserved.
//

import UIKit

public enum FitftyFont {
    case appleSDThin(size: CGFloat)
    case appleSDRegular(size: CGFloat)
    case appleSDUltraLight(size: CGFloat)
    case appleSDLight(size: CGFloat)
    case appleSDMedium(size: CGFloat)
    case appleSDSemiBold(size: CGFloat)
    case appleSDBold(size: CGFloat)

    case SFProDisplayBlack(size: CGFloat)
    case SFProDisplayBold(size: CGFloat)
    case SFProDisplayLight(size: CGFloat)
    case SFProDisplayMedium(size: CGFloat)
    case SFProDisplaySemibold(size: CGFloat)
    case SFProDisplayThin(size: CGFloat)
    
    case antonRegular(size: CGFloat)
}

extension FitftyFont {
    public var font: UIFont? {
        switch self {
        case .appleSDThin(let size):
            return UIFont(name: "AppleSDGothicNeo-Thin", size: size)
        case .appleSDRegular(let size):
            return UIFont(name: "AppleSDGothicNeo-Regular", size: size)
        case .appleSDUltraLight(let size):
            return UIFont(name: "AppleSDGothicNeo-UltraLight", size: size)
        case .appleSDLight(let size):
            return UIFont(name: "AppleSDGothicNeo-Light", size: size)
        case .appleSDMedium(let size):
            return UIFont(name: "AppleSDGothicNeo-Medium", size: size)
        case .appleSDSemiBold(let size):
            return UIFont(name: "AppleSDGothicNeo-SemiBold", size: size)
        case .appleSDBold(let size):
            return UIFont(name: "AppleSDGothicNeo-Bold", size: size)

        case .SFProDisplayBlack(let size):
            return CommonFontFamily.SFProDisplay.black.font(size: size)
        case .SFProDisplayBold(let size):
            return CommonFontFamily.SFProDisplay.bold.font(size: size)
        case .SFProDisplayLight(let size):
            return CommonFontFamily.SFProDisplay.light.font(size: size)
        case .SFProDisplayMedium(let size):
            return CommonFontFamily.SFProDisplay.medium.font(size: size)
        case .SFProDisplaySemibold(let size):
            return CommonFontFamily.SFProDisplay.semibold.font(size: size)
        case .SFProDisplayThin(let size):
            return CommonFontFamily.SFProDisplay.thin.font(size: size)
            
        case .antonRegular(let size):
            return CommonFontFamily.Anton.regular.font(size: size)
      }
    }
}
