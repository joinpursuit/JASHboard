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
            self.downvoteCount = jashImage?.votes.downvotes
            
            guard let category = jashImage?.category else { return }
            guard let imageId = jashImage?.imageId else { return }
            let storageReference = FIRStorage.storage().reference().child("\(category)/\(imageId)")
            
            //update picture
            storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
                DispatchQueue.main.async {
                    if let data = data {
                        self.photoImageView.image = UIImage(data: data)
                    }
                }
            })
        }
    }
    var upvoteCount: Int? = nil {
        willSet {
            DispatchQueue.main.async {
                self.upvoteNumberLabel.text = String(describing: newValue!)
            }
        }
    }
    var downvoteCount: Int? = nil {
        willSet {
            DispatchQueue.main.async {
                self.downvoteNumberLabel.text = String(describing: newValue!)
            }
        }
    }
    var selectedPhoto: UIImage!
    private let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    //tracking votes and users concurrently
    var votes: [(String, Bool)] = []
    var pictureTitle: String?
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        populateVotesArray()
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(self.doubleTapImage))
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(VoteTableViewCell.self, forCellReuseIdentifier: VoteTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    internal func populateVotesArray() {
        guard let photoID = jashImage?.imageId else { return }
        
        let databaseRef = FIRDatabase.database().reference(withPath: "USERS")
        
        //in order to update the tableview in real-time we have to constantly observe for a change in value of votes
        databaseRef.observe(.value, with: { (snapshot) in
            let enumerator = snapshot.children
            var currentVotes: [(String, Bool)] = []
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                let dictionary = child.value as! [String: AnyObject]
                
                if let name = dictionary["name"],
                    let photoVotes = dictionary["photoVotes"],
                    let voteResult = photoVotes[photoID] as? [String: AnyObject],
                    let voteBool = voteResult["voteType"] {
                    currentVotes.append((name as! String, voteBool as! Bool))
                }
            }
            self.votes = currentVotes
            self.tableView.reloadData()
        })
    }
    
    internal func vote(sender: UIButton) {
        guard let category = jashImage?.category,
            let imageId = jashImage?.imageId,
            let userId = FIRAuth.auth()?.currentUser?.uid else { return }
        
        //reference to the imageID in the respective CATEGORY node
        let databaseReference = FIRDatabase.database().reference(withPath: "\(category)/\(imageId)")
        
        databaseReference.runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
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
                
                //update photoVotes node within USERS node
                let userDBReference = FIRDatabase.database().reference().child("USERS/\(userId)/photoVotes")
                
                if let pictureTitle = self.pictureTitle {
                    sender.tag == 100 ? (userDBReference.child(imageId).setValue(["voteType" : true, "title" : pictureTitle])) : (userDBReference.child(imageId).setValue(["voteType" : false, "title" : pictureTitle]))
                }
            }
            return FIRTransactionResult.success(withValue: currentData)
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
        
        //TO DO: account for imageIcon and profile picture
        vote.1 == true ? (cell.voteDescription = "\(vote.0) voted up.") : (cell.voteDescription = "\(vote.0) voted down.")
        cell.imageIcon = UIImage(named: "siberian-tiger-profile")
        cell.date = Date()
        
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
        
        animator.startAnimation()
    }

    //MARK: - Views
    
    //tableView
    internal lazy var tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    //logo
    internal lazy var photoImageView: UIImageView = {
        let image = self.selectedPhoto
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
