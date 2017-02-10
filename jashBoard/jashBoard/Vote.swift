//
//  Vote.swift
//  jashBoard
//
//  Created by Harichandan Singh on 2/8/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation

class Vote {
    //MARK: - Properties
    var upvotes: Int
    var downvotes: Int
    
    //MARK: - Initializer
    init(upvotes: Int, downvotes: Int) {
        self.upvotes = upvotes
        self.downvotes = downvotes
    }
    
    init?(snapshot: [String: AnyObject]) {
        guard
            let upvotes = snapshot["upvotes"] as? Int,
            let downvotes = snapshot["downvotes"] as? Int
            else { return nil }
        
        self.upvotes = upvotes
        self.downvotes = downvotes
    }
}
