//
//  CategoryPhotosCollectionViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class CategoryPhotosCollectionViewController: UICollectionViewController {
    //MARK: - Properties
    var categoryTitle: String?
    var jashImages: [JashImage] = []

    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
        loadPhotosArray()
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jashImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
        let jashImage = jashImages[indexPath.row]
        
        // Configure the cell
        let storageReference = FIRStorage.storage().reference().child("\(jashImage.category)/\(jashImage.imageId)")
        
        storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
            
            DispatchQueue.main.async {
                cell.photo.image = UIImage(data: data!)
            }
        })
        
        //replace this?
        cell.upCount = jashImage.votes.upvotes
        cell.downCount = jashImage.votes.downvotes
        
        return cell
    }
    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let jashImage = self.jashImages[indexPath.row]
        
        if let navController = self.navigationController{
            let categoryController = IndividualPhotoViewController()
            categoryController.jashImage = jashImage
            
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
            navController.pushViewController(categoryController, animated: true)
        }
    }
    
    //MARK:- Utilities
    private func setUpCollectionView(){
        self.collectionView!.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.cellIdentifier)
        let layout = UICollectionViewFlowLayout()
        let screenSize = UIScreen.main.bounds
        
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenSize.width / 2 - 0.5, height: screenSize.width / 2 - 0.5 )
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.backgroundColor = JashColors.dividerColor
        collectionView?.collectionViewLayout = layout
       // self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.title = categoryTitle
    }
    
    private func loadPhotosArray() {
        guard let category = self.title?.uppercased() else { return }
        let databaseReference = FIRDatabase.database().reference().child("\(category)")
        
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Number of pictures: \(snapshot.childrenCount)")
            
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                
                let votesDictionary = child.value as! [String: AnyObject]
                guard let votes = Vote(snapshot: votesDictionary) else { return }
                let jashImage = JashImage(votes: votes, imageId: child.key, category: category)
                
                self.jashImages.append(jashImage)
            }
            self.collectionView?.reloadData()
        })
    }
}
