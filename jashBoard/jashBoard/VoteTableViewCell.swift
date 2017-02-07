//
//  VoteTableViewCell.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/7/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit

class VoteTableViewCell: UITableViewCell {
    static let cellIdentifier = "VoteCell"
    
    var voteDescription: String!
    var date: Date!
    var imageIcon: UIImage!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupPlaceHolderCellInfo()
        
        self.addSubview(photoImageView)
        self.addSubview(voteDescriptionLabel)
        self.addSubview(dateLabel)
        //Removes selection highlight
        self.selectionStyle = .none
        
        self.photoImageView.snp.makeConstraints { (view) in
            view.bottom.top.leading.equalToSuperview().inset(8.0)
            view.height.equalTo(40)
            view.width.equalTo(40)
        }

        self.dateLabel.snp.makeConstraints { (view) in
            view.centerY.equalTo(photoImageView.snp.centerY)
            view.trailing.equalToSuperview()
        }
        
        self.voteDescriptionLabel.snp.makeConstraints { (view) in
            view.centerY.equalTo(photoImageView.snp.centerY)
            view.leading.equalTo(photoImageView.snp.trailing).offset(8.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Placeholder - TODO: Delete this when we have info
    
    internal func setupPlaceHolderCellInfo() {
        self.date = Date()
        self.voteDescription = "Ruth Lindsey voted up"
        self.imageIcon = UIImage(named: "siberian-tiger-profile")
    }
    
    // MARK: - Views
    
    // Left Icon View
    internal lazy var photoImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = self.imageIcon
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = JashColors.primaryTextColor.cgColor
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // labels
    internal lazy var voteDescriptionLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.primaryTextColor
        label.text = self.voteDescription
        return label
    }()
    
    internal lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = JashColors.lightPrimaryColor
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: self.date)
        label.text = dateString
        return label
    }()
    
}
