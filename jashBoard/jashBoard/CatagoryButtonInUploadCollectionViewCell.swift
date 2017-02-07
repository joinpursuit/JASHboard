//
//  CatagoryButtonInUploadCollectionViewCell.swift
//  jashBoard
//
//  Created by Ana Ma on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

class CatagoryButtonInUploadCollectionViewCell: UICollectionViewCell {
    static let identifier = "catagoryButtonInUploadCellIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHierarchy() {
        self.addSubview(catagoryLabel)
    }
    
    func configureConstraints() {
        catagoryLabel.snp.makeConstraints { (label) in
            label.top.leading.equalToSuperview().offset(4)
            label.trailing.bottom.equalToSuperview().inset(4)
            //label.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    lazy var catagoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = JashColors.textAndIconColor
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = JashColors.primaryColor
        label.layer.borderColor = JashColors.primaryTextColor.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center
        return label
    }()
    
}
