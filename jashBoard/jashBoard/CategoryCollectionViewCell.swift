//
//  CategoryCollectionViewCell.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit

protocol JashCollectionViewCellDelegate{
    func showPopUpWith(image: UIImage)
    func hidePopUp()
}

class CategoryCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    static let cellIdentifier: String = "cellIdentifier"
    private let pressAndHold :UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    var cellImage: UIImage?{
        didSet{
            setupCell()
        }
    }
    var upCount: Int = 0
    var downCount: Int = 0
       
    private let padding: Int = 7
    internal static let arrowAlpha: CGFloat = 0.7
    
    var delegate: JashCollectionViewCellDelegate?
    
    //MARK: - Initializers
//    required override init(frame: CGRect) {
//        super.init(frame: frame)
//       
//        setupCell()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //MARK: - Methods
    private func setupCell(){
        self.addSubview(photo)
        self.addSubview(cellTint)
        self.addSubview(upvoteArrow)
        self.addSubview(downvoteArrow)
        self.addSubview(downCountLabel)
        self.addSubview(upCountLabel)
        
        cellTint.addGestureRecognizer(pressAndHold)
        self.photo.image = cellImage
        
        self.photo.snp.makeConstraints { (view) in
            view.bottom.top.leading.trailing.equalToSuperview()
        }
        self.cellTint.snp.makeConstraints { (view) in
            view.bottom.top.leading.trailing.equalToSuperview()
        }
        self.downvoteArrow.snp.makeConstraints { (view) in
            view.bottom.equalTo(self.snp.bottom).inset(padding)
            view.leading.equalTo(self.snp.leading).offset(padding)
            view.size.equalTo(15)
        }
        
        self.upvoteArrow.snp.makeConstraints { (view) in
            view.bottom.equalTo(downvoteArrow.snp.top).offset(-padding)
            view.leading.equalTo(self.snp.leading).offset(padding)
            view.size.equalTo(15)
        }
        
        self.downCountLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(downvoteArrow.snp.bottom)
            view.leading.equalTo(downvoteArrow.snp.trailing).offset(padding)
        }
        
        self.upCountLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(upvoteArrow.snp.trailing).offset(padding)
            view.bottom.equalTo(upvoteArrow.snp.bottom)
        }
        
        pressAndHold.addTarget(self, action: #selector(self.longPress))
        pressAndHold.minimumPressDuration = 0.5
    
        self.upCountLabel.text = String(upCount)
        self.downCountLabel.text = String(downCount)
    }
    
    //MARK: - Utilities
    
    internal func longPress(sender: UILongPressGestureRecognizer){
        print("Long Press")
        
        switch sender.state{
        case .began:
            self.delegate?.showPopUpWith(image: cellImage!)
        case .ended:
            self.delegate?.hidePopUp()
        default:
            break
        }
    }
    
    private let upCountLabel: UILabel = {
        let label : UILabel = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.alpha = arrowAlpha
        return label
    }()
    
    private let downCountLabel: UILabel = {
        let label : UILabel = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.alpha = arrowAlpha
        return label
    }()
    
    private let upvoteArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "up_arrow")
        imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = .white
        imageView.alpha = arrowAlpha
        return imageView
    }()
    
    private let downvoteArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "down_arrow")
        imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = .white
        imageView.alpha = arrowAlpha
        return imageView
    }()
    
    let photo: UIImageView = {
        let imageView: UIImageView = UIImageView()
        // imageView.image = UIImage(named: "siberian-tiger-profile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //Adds ting to cell so categories label is more visable
    private let cellTint: UIView = {
        let view:UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.2
        return view
    }()
}
