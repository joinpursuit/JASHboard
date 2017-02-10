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
            self.photoID = jashImage?.imageId
            self.upvoteCount = jashImage?.votes.upvotes
            self.downvoteCount = jashImage?.votes.downvotes
        }
    }
    
    //Calling dispatch queue here bogged UI down
    var upvoteCount: Int? = nil {
        willSet {
        //    DispatchQueue.main.async {
                self.upvoteNumberLabel.text = String(describing: newValue!)
         //   }
        }
    }
    var downvoteCount: Int? = nil {
        willSet {
        //    DispatchQueue.main.async {
                self.downvoteNumberLabel.text = String(describing: newValue!)
         //   }
        }
    }
    var selectedPhoto: UIImage!
    private let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer()
    var dbReference: FIRDatabaseReference!
    var storageReference: FIRStorageReference!
    var dbHandle: UInt!
    var photoID: String!
    
    //tracking votes and users concurrently
    var votes: [(name: String, type: Bool, time: String)] = []
    var pictureTitle: String?
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFirebaseReferences()
        
        loadImage()
        
        setupViewHierarchy()
        configureConstraints()
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(self.doubleTapImage))
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(VoteTableViewCell.self, forCellReuseIdentifier: VoteTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dbReference = FIRDatabase.database().reference().child("USERS")
        
        //Create listener and store handle
        self.dbHandle = self.dbReference.observe(.value, with: { (snapshot) in
            let enumerator = snapshot.children
            var currentVotes: [(String, Bool, String)] = []
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                let dictionary = child.value as! [String: AnyObject]
                
                if let name = dictionary["name"] as? String,
                    let photoVotes = dictionary["photoVotes"],
                    let voteResult = photoVotes[self.photoID] as? [String: AnyObject],
                    let voteType = voteResult["voteType"] as? Bool,
                    let voteTime = voteResult["voteTime"] as? String {
                    print("Vote Result: \(voteResult)")
                    
                    //handling
                    print("CURRENT USER: \(FIRAuth.auth()?.currentUser?.uid)")
                    if !(FIRAuth.auth()?.currentUser?.isAnonymous)! {
                        if voteResult != nil && voteType == true {
                            self.upvoteButton.isEnabled = false
                            self.downvoteButton.isEnabled = true
                        }
                        else if voteResult != nil && voteType == false {
                            self.downvoteButton.isEnabled = false
                            self.upvoteButton.isEnabled = true
                        }
                    }
                    currentVotes.append((name, voteType, voteTime))
                }
            }
            //sorting results by time of vote
            self.votes = currentVotes.sorted { $0.2 > $1.2 }
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Remove listener with handle
        self.dbReference.removeObserver(withHandle: self.dbHandle)
    }
    
    internal func initializeFirebaseReferences() {
        //Initializing reference to Firebase
        self.dbReference = FIRDatabase.database().reference()
        self.storageReference = FIRStorage.storage().reference()
    }
    
    internal func loadImage() {
        guard let category = jashImage?.category else { return }
        guard let id = self.photoID else { return }
        print(category)
        self.storageReference = FIRStorage.storage().reference().child("\(category)/\(id)")
        print(self.storageReference)
        self.storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
            DispatchQueue.main.async {
                if let data = data {
                    self.photoImageView.image = UIImage(data: data)
                }
            }
        })
    }
    
    internal func vote(sender: UIButton) {
        //if user is anonymous no upvoting or downvoting
        guard let userIsAnonymous = FIRAuth.auth()?.currentUser?.isAnonymous else { return }
        
        if userIsAnonymous {
            let alertController = UIAlertController(title: "Stranger danger!", message: "Please sign in or register to upvote/downvote!", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okay)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let category = jashImage?.category,
            let imageId = jashImage?.imageId,
            let userId = FIRAuth.auth()?.currentUser?.uid else { return }
        
        //reference to the imageID in the respective CATEGORY node
        self.dbReference = FIRDatabase.database().reference(withPath: "CATEGORIES/\(category)/\(imageId)")
        
        self.dbReference.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            //update upvote/downvote counter
            if var imageInfo = currentData.value as? [String: AnyObject] {
                var upvotes = imageInfo["upvotes"] as? Int
                var downvotes = imageInfo["downvotes"] as? Int
                self.pictureTitle = imageInfo["title"] as? String ?? "Default Title"
                
                if sender.tag == 100 {
                    upvotes! += 1
                    self.upvoteCount = upvotes!
                }
                else {
                    downvotes! += 1
                    self.downvoteCount = downvotes!
                }
                
                imageInfo["downvotes"] = downvotes as AnyObject?
                imageInfo["upvotes"] = upvotes as AnyObject?
                
                currentData.value = imageInfo
                
                self.dbReference = FIRDatabase.database().reference().child("USERS/\(userId)/photoVotes")
                let currentDateString = Date().convertToTimeString()
                
                if let pictureTitle = self.pictureTitle {
                    
                    let upvoteDict = [
                        "voteType" : true as AnyObject,
                        "title" : pictureTitle as AnyObject,
                        "voteTime" : currentDateString as AnyObject
                    ]
                    let downvoteDict: [String: AnyObject] = [
                        "voteType" : false as AnyObject,
                        "title" : pictureTitle as AnyObject,
                        "voteTime" : currentDateString as AnyObject
                    ]
                    
                    sender.tag == 100 ? (self.dbReference.child(imageId).setValue(upvoteDict)) : (self.dbReference.child(imageId).setValue(downvoteDict))
                }
            }
            return FIRTransactionResult.success(withValue: currentData)
        })
        // update current users photoVotes node
        self.dbReference = FIRDatabase.database().reference().child("USERS/\(userId)/photoVotes/\(imageId)")
        
        if let pictureTitle = self.pictureTitle {
            sender.tag == 100 ? (self.dbReference.setValue(["voteType" : true, "title" : pictureTitle, "category" : category, "timeStamp" : FIRServerValue.timestamp()])) : (self.dbReference.setValue(["voteType" : false, "title" : pictureTitle, "category" : category, "timeStamp" : FIRServerValue.timestamp()]))
        }
        
    }
    
    //MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(photoImageView)
        self.view.addSubview(upvoteButton)
        self.view.addSubview(downvoteButton)
        self.view.addSubview(upvoteNumberLabel)
        self.view.addSubview(downvoteNumberLabel)
        self.view.addSubview(tableView)
        self.photoImageView.addSubview(upArrow)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        //image
        photoImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
        }
        
        //photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(doubleTap)
        
        //labels
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
        
        //buttons
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
        
        //tableView
        tableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(self.view.snp.centerY)
        }
        
        //upArrow animation
        
        upArrow.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    //MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.votes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteTableViewCell.cellIdentifier, for: indexPath) as! VoteTableViewCell
        let vote = votes[indexPath.row]
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            vote.type == true ? (cell.voteDescription = "\(vote.name) voted up.") : (cell.voteDescription = "\(vote.name) voted down.")
            cell.dateLabel.text = vote.time
            
            self.storageReference = FIRStorage.storage().reference().child("ProfilePictures/\(uid)")
            
            storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
                if let imageData = data {
                    DispatchQueue.main.async {
                        cell.imageIcon = UIImage(data: imageData)
                    }
                }
            })
        }
        return cell
    }
    
    //MARK: Utilities
    internal func doubleTapImage(){
        let animator :UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.5)
        
        self.photoImageView.isUserInteractionEnabled = false
        animator.addAnimations {
            self.upArrow.alpha = 0.7
            self.upArrow.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        animator.addAnimations({
            self.upArrow.transform = CGAffineTransform(translationX: 0, y: -300)
        }, delayFactor: 0.5)
        
        animator.addCompletion { (postion) in
            if postion == .end{
                self.upArrow.alpha = 0
                self.upArrow.transform = CGAffineTransform.identity
                self.photoImageView.isUserInteractionEnabled = true
            }
        }
        
        //if user is anonymous the vote will not occur or animate
        if !(FIRAuth.auth()?.currentUser?.isAnonymous)! {
            vote(sender: self.upvoteButton)
            animator.startAnimation()
        }
        else {
            //will hit guard statement at the top of this function and throw "Stranger Danger" alert.
            vote(sender: self.upvoteButton)
        }
    
    }
    
    //MARK: - Views
    
    //tableView
    internal lazy var tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    //logo
    internal lazy var photoImageView: UIImageView = {
        //selected photo is always nil replaced with default photo
        let image = #imageLiteral(resourceName: "default-placeholder")
       // let image = self.selectedPhoto
        let imageView: UIImageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    //buttons
    internal lazy var upvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.tintColor = JashColors.accentColor
        button.backgroundColor = JashColors.darkPrimaryColor(alpha: 0.75)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        button.tag = 100
        button.addTarget(self, action: #selector(vote(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    internal lazy var downvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "down_arrow"), for: .normal)
        button.tintColor = JashColors.accentColor
        button.backgroundColor = JashColors.darkPrimaryColor(alpha: 0.75)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        button.tag = 101
        button.addTarget(self, action: #selector(vote(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    //labels
    internal lazy var upvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = String(describing: self.upvoteCount)
        label.textAlignment = .center
        return label
    }()
    
    internal let upArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "up_arrow")
        imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = .white
        imageView.alpha = 0
        return imageView
    }()
    
    internal lazy var downvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = String(describing: self.downvoteCount)
        label.textAlignment = .center
        return label
    }()
}
