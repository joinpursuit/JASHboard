//
//  jashImage.swift
//  jashBoard
//
//  Created by Harichandan Singh on 2/8/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation

class JashImage {
    //MARK: - Properties
    var votes: Vote
    let imageId: String
    let category: String
    
    //MARK: - Initializer
    init(votes: Vote, imageId: String, category: String) {
        self.votes = votes
        self.imageId = imageId
        self.category = category
    }
}
