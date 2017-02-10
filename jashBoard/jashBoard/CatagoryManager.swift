//
//  CatagoryManager.swift
//  jashBoard
//
//  Created by Ana Ma on 2/10/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation
import UIKit

class CategoryManager {
    static let shared = CategoryManager()
    var catagoryTitlesArray: [String] = ["ANIMALS", "BEACH DAYS", "CARS", "PLANTS", "FOOD", "FINE ARTS", "PLACES"]
    var catagoryImages: [UIImage] = [#imageLiteral(resourceName: "animals"),#imageLiteral(resourceName: "beach-day"),#imageLiteral(resourceName: "cars"),#imageLiteral(resourceName: "plants"),#imageLiteral(resourceName: "food"),#imageLiteral(resourceName: "fine-arts"),#imageLiteral(resourceName: "places")]
}
