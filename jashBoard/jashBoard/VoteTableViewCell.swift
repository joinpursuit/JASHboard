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
    
    var voteDescription: String? {
        didSet{
            setDescriptionLabel()
        }
    }
    var date: Date? {
        didSet{
            setDateLabel()
        }
    }
    var imageIcon: UIImage? {
        didSet{
            setImageIcon()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.addSubview(photoImageView)
        self.addSubview(voteDescriptionLabel)
        self.addSubview(dateLabel)
        //Removes selection highlight
        self.selectionStyle = .none
    }
    
    private func configureConstraints() {
        self.photoImageView.snp.makeConstraints { (view) in
            view.bottom.top.leading.equalToSuperview().inset(8.0)
            view.height.equalTo(40)
            view.width.equalTo(40)
        }
        self.dateLabel.snp.makeConstraints { (view) in
            view.centerY.equalTo(photoImageView.snp.centerY)
            view.trailing.equalToSuperview().inset(8.0)
        }
        self.voteDescriptionLabel.snp.makeConstraints { (view) in
            view.centerY.equalTo(photoImageView.snp.centerY)
            view.leading.equalTo(photoImageView.snp.trailing).offset(8.0)
        }
    }
    
    // MARK: - Set labels
    func setDateLabel() {
        let formatter = DateFormatter()
        if formatter.calendar.isDateInToday(self.date!) {
            formatter.dateStyle = DateFormatter.Style.none
        } else {
            formatter.dateStyle = DateFormatter.Style.short
        }
        
        formatter.timeStyle = .short
        let dateString = formatter.string(from: self.date!)
        dateLabel.text = dateString
    }
    
    func setDescriptionLabel() {
        voteDescriptionLabel.text = self.voteDescription!
    }
    
    func setImageIcon() {
        photoImageView.image = self.imageIcon
    }
    
    // MARK: - Views

    internal lazy var photoImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = JashColors.primaryTextColor.cgColor
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.image = nil
        return imageView
    }()
    
    internal lazy var voteDescriptionLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.primaryTextColor
        label.text = nil
        return label
    }()
    
    internal lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = JashColors.lightPrimaryColor
        label.text = nil
        return label
    }()
}
