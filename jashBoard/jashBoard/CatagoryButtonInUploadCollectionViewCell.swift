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
            label.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    lazy var catagoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
}
