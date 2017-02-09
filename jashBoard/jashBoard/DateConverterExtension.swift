//
//  DateConverterExtension.swift
//  jashBoard
//
//  Created by Harichandan Singh on 2/9/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation

extension Date {
    
    func convertToTimeString(input: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: input)
    }
    
}
