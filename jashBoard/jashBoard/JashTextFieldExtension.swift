//
//  JashTextFieldExtension.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/7/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation
import UIKit


extension UITextField{

    func underLine(placeHolder: String = ""){

        let str = NSAttributedString(string: placeHolder.uppercased(), attributes: [NSForegroundColorAttributeName:JashColors.accentColor])
        self.attributedPlaceholder = str
        
        
        let border = CALayer()
        let width = CGFloat(2.0)
        
        self.snp.makeConstraints { (view) in
            view.width.equalTo(300)
        }
        
        self.layoutIfNeeded()
        
        border.borderColor = JashColors.textAndIconColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
//        self.borderStyle = .none
//        self.layer.backgroundColor = UIColor.white.cgColor
//        
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.red.cgColor
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 0.0
    }
    
}
