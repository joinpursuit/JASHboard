//
//  JashTextField.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

class JashTextField: UITextField {

    convenience init(placeHolder: String) {
        self.init()
        self.placeholder = placeHolder
        
        let str = NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName:JashColors.accentColor])
        self.attributedPlaceholder = str
        
        self.snp.makeConstraints { (view) in
            view.width.equalTo(300)
        }
        self.layoutIfNeeded()
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.red.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = self.frame.width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true

    }

}
