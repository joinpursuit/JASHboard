//
//  Utilities.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

// Source: http://crunchybagel.com/working-with-hex-colors-in-swift-3/

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
    }
}

// MARK: - Colors
struct JashColors {
    static let darkPrimaryColor = UIColor(hex: "455A64")
    static let primaryColor = UIColor(hex: "607D8B")
    static let lightPrimaryColor = UIColor(hex: "CFD8DC")
    static let textAndIconColor = UIColor(hex: "FFFFFF")
    static let accentColor = UIColor(hex: "FFD740")
    static let primaryTextColor = UIColor(hex: "212121")
    static let secondaryTextColor = UIColor(hex: "727272")
    static let dividerColor = UIColor(hex: "B6B6B6")
    
    static let colorsDict = [
        "darkPrimaryColor" : "455A64",
        "primaryColor" : "607D8B",
        "lightPrimaryColor" : "CFD8DC",
        "textAndIconColor" : "FFFFFF",
        "accentColor" : "FFD740",
        "primaryTextColor" : "212121",
        "secondaryTextColor" : "727272",
        "dividerColor" : "B6B6B6"
    ]
    
    // transparency
    static func darkPrimaryColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["darkPrimaryColor"]!, alpha: alpha)
    }
    static func primaryColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["primaryColor"]!, alpha: alpha)
    }
    static func lightPrimaryColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["lightPrimaryColor"]!, alpha: alpha)
    }
    static func textAndIconColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["textAndIconColor"]!, alpha: alpha)
    }
    static func accentColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["accentColor"]!, alpha: alpha)
    }
    static func primaryTextColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["primaryTextColor"]!, alpha: alpha)
    }
    static func secondaryTextColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["secondaryTextColor"]!, alpha: alpha)
    }
    static func dividerColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: self.colorsDict["dividerColor"]!, alpha: alpha)
    }    
}
