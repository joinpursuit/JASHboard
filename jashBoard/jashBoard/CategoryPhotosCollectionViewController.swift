//
//  CategoryPhotosCollectionViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategoryPhotosCollectionViewController: UICollectionViewController {
    var categoryTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
    }
    
        // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
    
        // Configure the cell
        cell.downCount = 20
    
        return cell
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
    

}
