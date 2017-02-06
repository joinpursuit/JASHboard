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
    convenience init(hex: String) {
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
            blue: CGFloat(b) / 0xff, alpha: 1
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
}
