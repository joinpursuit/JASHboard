//
//  UserHomeViewController.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/7/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

class UserHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var votes: [String]! // Would probably be type Vote
    var userPhoto: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceHolderCellInfo()
        
        setupViewHierarchy()
        configureConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(VoteTableViewCell.self, forCellReuseIdentifier: VoteTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }

    // MARK: - Placeholder - TODO: Delete this when we have info
    
    internal func setupPlaceHolderCellInfo() {
        self.votes = ["You voted this photo up", "You voted this photo down"]
        self.userPhoto = UIImage(named: "siberian-tiger-profile")
    }
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(photoImageView)
        self.view.addSubview(tableView)
        self.view.addSubview(collectionContainerView)
        self.view.addSubview(yourUploadsLabel)
        
        collectionContainerView.addSubview(collectionView)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        photoImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.snp.height).multipliedBy(0.3)
        }
        
        yourUploadsLabel.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
        }
        
        collectionContainerView.snp.makeConstraints { (view) in
            view.bottom.equalTo(yourUploadsLabel.snp.top)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(80.0)
        }
        
        collectionView.snp.makeConstraints { (view) in
            view.leading.top.trailing.bottom.equalToSuperview()
        }

        tableView.snp.makeConstraints { (view) in
            view.top.equalTo(photoImageView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(collectionView.snp.top)
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return votes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteTableViewCell.cellIdentifier, for: indexPath) as! VoteTableViewCell
        
        //        cell.categoryTitleLabel.text = categories[indexPath.row]
        
        return cell
    }
    
    // MARK: - CollectionView Delegates

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return votes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    // MARK: - Views
    
    // user image
    internal lazy var photoImageView: UIImageView = {
        let image = self.userPhoto
        let imageView: UIImageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // tableView
    internal lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .blue
        return tableview
    }()
    
    // collectionView
    lazy var collectionContainerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    internal lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: self.collectionContainerView.frame, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .yellow
        return collectionView
    }()
    
    // Label
    internal lazy var yourUploadsLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = "YOUR UPLOADS"
        label.textAlignment = .left
        return label
    }()
}
