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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellBackgroundImage)
        self.addSubview(cellTint)
        self.addSubview(categoryTitleLabel)
        //Removes selection highlight
        self.selectionStyle = .none
        
        self.cellBackgroundImage.snp.makeConstraints { (view) in
            view.bottom.top.leading.trailing.equalToSuperview()
            view.height.equalTo(200)
        }
        
        self.cellTint.snp.makeConstraints { (view) in
            view.bottom.top.leading.trailing.equalToSuperview()
        }
        self.categoryTitleLabel.snp.makeConstraints { (view) in
            view.centerX.equalTo(self.snp.centerX)
            view.centerY.equalTo(self.snp.centerY)
            view.height.equalTo(self.snp.height).multipliedBy(0.3)
            view.width.equalTo(self.snp.width).multipliedBy(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //Background image for cell
    let cellBackgroundImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "siberian-tiger-profile")
        return imageView
    }()
    //Adds tint to cell so categories label is more visable
    private let cellTint: UIView = {
        let view:UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.1
        return view
    }()
    //Category label
    let categoryTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: 10)
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center
        return label
    }()
    
}
