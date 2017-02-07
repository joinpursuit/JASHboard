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
        self.addSubview(catagoryButton)
    }
    
    func configureConstraints() {
        catagoryButton.snp.makeConstraints { (view) in
            view.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    lazy var catagoryButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        return button
    }()
}
