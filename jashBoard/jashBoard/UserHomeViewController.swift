//
//  UserHomeViewController.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/7/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import Firebase

class UserHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    var photoIds: [(id: String, category: String, title: String)] = []
    var votes: [(id: String, title: String, voteType: Bool, category: String, timeStamp: Date)] = []
    var userPhoto: UIImage!
    var userUploads: [UIImage]!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceHolderCellInfo()
        setupViewHierarchy()
        configureConstraints()
        
        // TableView and Collection View Delegates and DataSource
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(VoteTableViewCell.self, forCellReuseIdentifier: VoteTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoInUploadCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInUploadCollectionViewCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        populatePhotoIdsArray()
        populateVotesArray()
    }

    internal func populatePhotoIdsArray() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let databaseReference = FIRDatabase.database().reference(withPath: "USERS/\(uid)/\("uploads")")
        print("Database reference: \(databaseReference)")
        
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                let key = child.key
                guard let imageInfo = child.value as? [String: AnyObject],
                    let category = imageInfo["category"] as? String,
                    let title = imageInfo["title"] as? String else { return }
                
                self.photoIds.append((key, category, title))
            }
            self.collectionView.reloadData()
        })
    }
    
    //add name to the votes array and continue re-factoring
    internal func populateVotesArray() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let databaseReference = FIRDatabase.database().reference(withPath: "USERS/\(uid)/\("photoVotes")")
        print("Database reference: \(databaseReference)")
        
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                let key = child.key
                guard let imageInfo = child.value as? [String: AnyObject],
                    let imageName = imageInfo["title"] as? String,
                    let bool = imageInfo["voteType"] as? Bool,
                    let category = imageInfo["category"] as? String,
                    let timeInterval = imageInfo["timeStamp"] as? TimeInterval
                else { continue }

                print(Date(timeIntervalSince1970: timeInterval/1000))
                let timeStamp = Date(timeIntervalSince1970: timeInterval/1000)
                self.votes.append((key, imageName, bool, category, timeStamp))
            }
            self.tableView.reloadData()
        })
    }
    
    //MARK: - Placeholder - TODO: Delete this when we have info
    internal func setupPlaceHolderCellInfo() {
        //use image picker controller to set profile picture via this property
        self.userPhoto = UIImage(named: "siberian-tiger-profile")
        self.userUploads = [self.userPhoto]
    }
    
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem  = logOutButton
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
        let vote = self.votes[indexPath.row]
        
        // Vote Description
        vote.voteType == true ? (cell.voteDescription = "You voted \(vote.title) up.") : (cell.voteDescription = "You voted \(vote.title) down.")
        
        // Image Icon and Date Created
        
        let storageReference = FIRStorage.storage().reference(withPath: "\(vote.category)/\(vote.id)")
        print("Storage reference: \(storageReference)")
        
        cell.imageIcon = UIImage(named: "siberian-tiger-profile")
        cell.dateLabel.text = Date().convertToTimeString()

        storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.imageIcon = UIImage(data: data)
                }
            }
        }
        
        storageReference.metadata { (metadata, error) in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    cell.date = metadata.timeCreated
                }
            }
        }
        return cell
    }
    
    // MARK: - CollectionView Delegates

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInUploadCollectionViewCell.identifier, for: indexPath) as! PhotoInUploadCollectionViewCell
        
        let imageID = self.photoIds[indexPath.row]
        
        let storageReference = FIRStorage.storage().reference(withPath: "\(imageID.category)/\(imageID.id)")
        print("Storage reference: \(storageReference)")
        
        storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
            
            if let data = data {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    // MARK: - Actions
    
    func didTapLogout(sender: UIButton) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let alertController = UIAlertController(title: "Logged Out Successfully", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel) { _ in
                //self.navigationController?.dismiss(animated: true, completion: nil)
                //self.navigationController?.popViewController(animated: true)
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(okay)
            present(alertController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Views
    
    // logout button
    internal lazy var logOutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "LOG OUT", style: .plain, target: self, action: #selector(self.didTapLogout(sender:)))
        return button
    }()
    
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
