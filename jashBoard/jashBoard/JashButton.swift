//
//  JashButton.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/7/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

class JashButton: UIButton {

    static let defaultSize = CGSize(width: 200, height: 20)
    convenience init(title: String) {
        self.init()
        
        self.setTitle(title.uppercased(), for: .normal)
        self.backgroundColor = .clear
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        self.setTitleColor(JashColors.textAndIconColor, for: .normal)
        self.layer.borderColor = JashColors.textAndIconColor.cgColor
        self.layer.borderWidth = 1.0
        //self.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        
    }

}
