//
//  CategoryCollectionViewCell.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier: String = "cellIdentifier"
    let upCount: Int = 20
    private let padding: Int = 5
    var downCount: Int = 20{
        didSet{
         setupCell()
        }
    }
    
    private func setupCell(){
        self.addSubview(photo)
        self.addSubview(upvoteArrow)
        self.addSubview(downvoteArrow)
        self.addSubview(downCountLabel)
        self.addSubview(upCountLabel)

        self.photo.snp.makeConstraints { (view) in
            view.top.equalTo(self.snp.top)
            view.bottom.equalTo(self.snp.bottom)
            view.leading.equalTo(self.snp.leading)
            view.trailing.equalTo(self.snp.trailing)
        }
        
        self.downvoteArrow.snp.makeConstraints { (view) in
            view.bottom.equalTo(self.snp.bottom).inset(padding)
            view.leading.equalTo(self.snp.leading).offset(padding)
            view.size.equalTo(15)
        }
        
        self.upvoteArrow.snp.makeConstraints { (view) in
            view.bottom.equalTo(downvoteArrow.snp.top)
            view.leading.equalTo(self.snp.leading).offset(padding)
            view.size.equalTo(15)
        }
        
        self.downCountLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(self.snp.bottom)
            view.leading.equalTo(downvoteArrow.snp.trailing).offset(padding)

        }
        
        self.upCountLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(upvoteArrow.snp.trailing)
            view.bottom.equalTo(downCountLabel.snp.top).offset(padding)

        }
        
    }
    
    
    private let upCountLabel: UILabel = {
        let label : UILabel = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 50)
        return label
    }()
    
    private let downCountLabel: UILabel = {
        let label : UILabel = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 50)
        return label
    }()
    
    private let upvoteArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "up_arrow")
        imageView.tintColor = .white
        return imageView
    }()
    
    private let downvoteArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "down_arrow")
        imageView.tintColor = .white
        return imageView
    }()
    
    let photo: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "siberian-tiger-profile")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
}
