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
    var photoIds: [(id: String, category: String, title: String, timeStamp: Date)] = []
    var votes: [(id: String, title: String, voteType: Bool, category: String, timeStamp: Date)] = []
    var userUploads: [UIImage]? = []
    var tableViewData: [(dataType: String, title: String, category: String, id: String, voteType: Bool?, timeStamp: Date)] = []
    
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
        setProfilePictureView()
        populateVotesArray()
        populatePhotoIdsArray()
        //self.animateUploads()
    }

    internal func setProfilePictureView(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let storageReference = FIRStorage.storage().reference(withPath: "ProfilePictures/\(uid)")
        print("Storage reference: \(storageReference)")
        
        storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: data)
                }
            }
        }
    }

    internal func populatePhotoIdsArray() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let databaseReference = FIRDatabase.database().reference(withPath: "USERS/\(uid)/\("uploads")")
        print("Database reference: \(databaseReference)")
        var currentIds: [(String, String, String, Date)] = []
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                let key = child.key
                guard let imageInfo = child.value as? [String: AnyObject],
                    let category = imageInfo["category"] as? String,
                    let title = imageInfo["title"] as? String,
                    let timeInterval = imageInfo["timeStamp"] as? TimeInterval
                else { continue }
                let timeStamp = Date(timeIntervalSince1970: timeInterval/1000)
                currentIds.append((key, category, title, timeStamp))
            }
            self.photoIds = currentIds
            self.collectionView.reloadData()
            self.loadTableViewData()
            self.tableView.reloadData()
        })
    }
    
    internal func populateVotesArray() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let databaseReference = FIRDatabase.database().reference(withPath: "USERS/\(uid)/\("photoVotes")")
        print("Database reference: \(databaseReference)")
        var currentVotes: [(id: String, title: String, voteType: Bool, category: String, timeStamp: Date)] = []
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
                let timeStamp = Date(timeIntervalSince1970: timeInterval/1000)
                currentVotes.append((key, imageName, bool, category, timeStamp))
            }
            self.votes = currentVotes
            self.loadTableViewData()
            self.tableView.reloadData()
        })
    }
    
    internal func loadTableViewData() {
        tableViewData = []
        for upload in photoIds {
            self.tableViewData.append((dataType: "photoId", title: upload.title, category: upload.category, id: upload.id, voteType: nil,timeStamp: upload.timeStamp))
        }
        for vote in votes {
            tableViewData.append((dataType: "vote", title: vote.title, category: vote.category, id: vote.id, voteType: vote.voteType,timeStamp: vote.timeStamp))
        }
        tableViewData.sort { $0.timeStamp > $1.timeStamp }
    }
    
    //MARK: - Placeholder - TODO: Delete this when we have info
    internal func setupPlaceHolderCellInfo() {
        //use image picker controller to set profile picture via this property
        self.userUploads = [UIImage(named: "siberian-tiger-profile")!]
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
    
    func animateUploads(){
        
        if photoIds.count == userUploads?.count{
            photoImageView.animationImages = userUploads
            photoImageView.animationDuration = 1
            photoImageView.startAnimating()
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteTableViewCell.cellIdentifier, for: indexPath) as! VoteTableViewCell
        cell.alpha = 0
        
        let voteAndUpload = tableViewData[indexPath.row]

        if voteAndUpload.dataType == "vote" {
            let vote = voteAndUpload
            vote.voteType == true ? (cell.voteDescription = "You voted \(vote.title) up.") : (cell.voteDescription = "You voted \(vote.title) down.")
            // Image Icon
            let storageReference = FIRStorage.storage().reference(withPath: "\(vote.category)/\(vote.id)")
            print("Storage reference: \(storageReference)")
            
            storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageIcon = UIImage(data: data)
                        UIView.animate(withDuration: 0.5, animations: {
                            cell.alpha = 1
                        })
                    }
                }
            }
            // Date Created
            cell.date = vote.timeStamp
        } else {
            let photoUpload = voteAndUpload
            
            // Cell text
            cell.voteDescription = "You uploaded \(photoUpload.title)."
            // Image icon
            let storageReference = FIRStorage.storage().reference(withPath: "\(photoUpload.category)/\(photoUpload.id)")
            print("Storage reference: \(storageReference)")
            
            storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageIcon = UIImage(data: data)
                        UIView.animate(withDuration: 0.5, animations: {
                            cell.alpha = 1
                        })
                    }
                }
            }
            cell.date = photoUpload.timeStamp
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
        cell.alpha = 0
        let imageID = self.photoIds[indexPath.row]
        
        let storageReference = FIRStorage.storage().reference(withPath: "\(imageID.category)/\(imageID.id)")
        print("Storage reference: \(storageReference)")
        
        storageReference.data(withMaxSize: Int64.max) { (data: Data?, error: Error?) in
            
            if let data = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    cell.imageView.image = image
                    self.userUploads?.append(image!)
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.alpha = 1
                    })
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
        
        //Instead of having a currentUser == nil, we force them to sign in Anonymously after logging out
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Error attempting to long in anonymously: \(error!)")
            }
            if user != nil {
                print("Signed in anonymously!")
            }
        })
    }
    
    // MARK: - Views
    
    // logout button
    internal lazy var logOutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "LOG OUT", style: .plain, target: self, action: #selector(self.didTapLogout(sender:)))
        return button
    }()
    
    // user image
    lazy var photoImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // tableView
    internal lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = JashColors.lightPrimaryColor
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
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = JashColors.lightPrimaryColor
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
