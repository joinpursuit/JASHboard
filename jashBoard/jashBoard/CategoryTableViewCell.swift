//
//  CategoryTableViewCell.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import SnapKit
class CategoryTableViewCell: UITableViewCell {
    static let cellIdentifier = "CategoryCell"
    var cellCategory: String?{
        didSet{
            setUpCell()
        }
    }
    let cellBackgroundImage: UIImageView =  UIImageView()
    let categoryLabel: UILabel = UILabel()



    func setUpCell(){
        categoryLabel.text = cellCategory
        self.addSubview(cellBackgroundImage)
        self.addSubview(categoryLabel)
        
        self.snp.makeConstraints { (view) in
            view.height.equalTo(200)
        }
        
        self.cellBackgroundImage.snp.makeConstraints { (view) in
            view.top.bottom.width.height.equalToSuperview()
        }
        self.categoryLabel.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
        }
        
        cellBackgroundImage.image = UIImage(named: "siberian-tiger-profile")
    }
    
    
    


}
