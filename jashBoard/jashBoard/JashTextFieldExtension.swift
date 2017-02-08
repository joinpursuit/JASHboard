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
            view.width.equalTo(350)
        }
        
        self.layoutIfNeeded()
        
        border.borderColor = JashColors.textAndIconColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true

    }
    
}
