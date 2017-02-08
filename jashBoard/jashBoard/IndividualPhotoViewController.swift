//
//  IndividualPhotoViewController.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class IndividualPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - Properties
    var jashImage: JashImage? = nil {
        didSet {
            self.upvoteCount = jashImage?.votes.upvotes
            self.upvoteNumberLabel.text = String(upvoteCount)
            self.downvoteCount = jashImage?.votes.downvotes
            self.downvoteNumberLabel.text = String(downvoteCount)
            
            guard let category = jashImage?.category else { return }
            guard let imageId = jashImage?.imageId else { return }
            let storageReference = FIRStorage.storage().reference().child("\(category)/\(imageId)")
            
            //update picture
            storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: data!)
                }
            })
        }
    }
    var upvoteCount: Int!
    var downvoteCount: Int!
    var selectedPhoto: UIImage!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registerForNotifications()
        setupPlaceHolderCellInfo()
        
        setupViewHierarchy()
        configureConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(VoteTableViewCell.self, forCellReuseIdentifier: VoteTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Placeholder - TODO: Delete this when we have info
    
    internal func setupPlaceHolderCellInfo() {                      
        //self.votes = ["So and So voted up", "So and so voted down"]
        self.selectedPhoto = UIImage(named: "siberian-tiger-profile")
        self.upvoteCount = 0
        self.downvoteCount = 0
    }
    

    
//    func updateWithJashImage(sender: Notification) {
//        guard let jashObject = sender.object as? JashImage else {
//            print("The Notification Center did not get this!")
//            return
//        }
//        self.jashImage = jashObject
//        dump(jashObject)
//        
//        let storageReference = FIRStorage.storage().reference().child("\(jashObject.category)/\(jashObject.imageId)")
//
//        storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
//            DispatchQueue.main.async {
//                //self.photoImageView.image = UIImage(data: data!)
//                //self.selectedPhoto
//                
//            }
//        })
//
//    }
    
//    func vote(imageId: String, flag: Bool) {
//        //hard-coded category but that will have to be changed with index path of collection/table view
//        var databaseReference = FIRDatabase.database().reference()
//        
//        flag == true ? (databaseReference = FIRDatabase.database().reference(withPath: "CategoryA/\(imageId)/upvotes")) : (databaseReference = FIRDatabase.database().reference(withPath: "CategoryA/\(imageId)/downvotes"))
//        
//        databaseReference.runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
//            var value = currentData.value as? Int
//            
//            if value == nil {
//                value = 0
//            }
//            
//            currentData.value = value! + 1
//            
//            return FIRTransactionResult.success(withValue: currentData)
//        }
//    }
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(photoImageView)
        self.view.addSubview(upvoteButton)
        self.view.addSubview(downvoteButton)
        self.view.addSubview(upvoteNumberLabel)
        self.view.addSubview(downvoteNumberLabel)
        self.view.addSubview(tableView)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        // image
        photoImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
        }
        
        // labels
        upvoteNumberLabel.snp.makeConstraints { (view) in
            view.leading.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
            view.trailing.equalTo(self.view.snp.centerX)
        }
        
        downvoteNumberLabel.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
            view.leading.equalTo(self.view.snp.centerX)
        }
        
        // buttons
        upvoteButton.snp.makeConstraints { (view) in
            view.leading.equalToSuperview()
            view.bottom.equalTo(upvoteNumberLabel.snp.top)
            view.trailing.equalTo(self.view.snp.centerX)
        }
        
        downvoteButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.bottom.equalTo(upvoteNumberLabel.snp.top)
            view.leading.equalTo(self.view.snp.centerX)
        }
        
        // tableView
        tableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(self.view.snp.centerY)
        }
    }
    
    // MARK: - TableView Delegates

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return votes.count
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteTableViewCell.cellIdentifier, for: indexPath) as! VoteTableViewCell
        
//        cell.categoryTitleLabel.text = categories[indexPath.row]
        
        return cell
    }


    // MARK: - Views
    
    // tableView
    internal lazy var tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    // logo
    internal lazy var photoImageView: UIImageView = {
        let image = self.selectedPhoto
        let imageView: UIImageView = UIImageView(image: image)
        //let imageView: UIImageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // buttons
    internal lazy var upvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.tintColor = JashColors.accentColor
        button.backgroundColor = JashColors.darkPrimaryColor(alpha: 0.75)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        
        //button.addTarget(self, action: #selector(), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    internal lazy var downvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "down_arrow"), for: .normal)
        button.tintColor = JashColors.accentColor
        button.backgroundColor = JashColors.darkPrimaryColor(alpha: 0.75)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        
        //button.addTarget(self, action: #selector(), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    // labels
    internal lazy var upvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = String(self.upvoteCount)
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var downvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = String(self.downvoteCount)
        label.textAlignment = .center
        return label
    }()
}
