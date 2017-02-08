//
//  UploadViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import SnapKit
import Photos
import Firebase
import FirebaseAuth

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var catagoryTitlesArr: [String] = ["ANIMALS", "BEACH DAYS" ,"CARS", "FLOWERS & PLANTS"]
    var photoAssetsArr: [PHAsset] = []
    
    let manager = PHImageManager.default()
    
    let uploadBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "up_arrow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadPhotoToFireBaseButtonPressed))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UPLOAD"
        self.tabBarItem.title = ""
        self.view.backgroundColor = JashColors.darkPrimaryColor
        
        setupViewHierarchy()
        configureConstraints()
        
        //Register Cells
        self.imagePickerCollectionView.register(PhotoInUploadCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInUploadCollectionViewCell.identifier)
        self.catagoryCollectionView.register(CatagoryButtonInUploadCollectionViewCell.self, forCellWithReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier)
        
        //Setup Navigation Bar
        self.navigationItem.rightBarButtonItem = uploadBarButton
        
        //Fetch Photos
        fetchPhotos()
        
        //Firebase
        let _ = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            guard let validUser = user else { return }
            if validUser.email == nil {
                self.uploadBarButton.isEnabled = false
            } else {
                self.uploadBarButton.isEnabled = true
            }
        })
    }
    
    // MARK: - Functions
    func uploadPhotoToFireBaseButtonPressed(_ sender: UIBarButtonItem) {
        print("uploadPhotoToFireBaseButtonPressed")
    }

    func fetchPhotos() {
        let momentsList = PHCollectionList.fetchMomentLists(with: PHCollectionListSubtype.momentListCluster, options: nil)
        
        for i in 0..<momentsList.count {
            let moments: PHCollectionList = momentsList[i]
            
            let collectionList = PHCollectionList.fetchCollections(in: moments, options: nil)
            for i in 0..<collectionList.count {
                let results = PHAsset.fetchAssets(in: collectionList[i] as! PHAssetCollection, options: nil)
                results.enumerateObjects({ (object: PHAsset, _, _) in
                    self.photoAssetsArr.append(object)
                })
            }
            dump(self.photoAssetsArr)
        }
    }
    
    
    // MARK: - CollectionViewDelegate & CollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case imagePickerCollectionView:
            return self.photoAssetsArr.count
        case catagoryCollectionView:
            return self.catagoryTitlesArr.count
        default:
            return self.catagoryTitlesArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case imagePickerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInUploadCollectionViewCell.identifier, for: indexPath) as! PhotoInUploadCollectionViewCell
            
            //let photo = photosArr[indexPath.row]
            let photo = photoAssetsArr[indexPath.row]
            
            manager.requestImage(for: photo, targetSize: cell.imageView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                cell.imageView.image = image
            })
            
            cell.backgroundColor = .white
            return cell
        case catagoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier, for: indexPath) as! CatagoryButtonInUploadCollectionViewCell
            
            let catagoryTitle = catagoryTitlesArr[indexPath.row]
            cell.catagoryLabel.text = catagoryTitle

            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier, for: indexPath) as! CatagoryButtonInUploadCollectionViewCell
            
            let catagoryTitle = catagoryTitlesArr[indexPath.row]
            cell.catagoryLabel.text = catagoryTitle
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case imagePickerCollectionView:
            print(photoAssetsArr[indexPath.row])
            let photo = photoAssetsArr[indexPath.row]
            manager.requestImage(for: photo, targetSize: selectedImageView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                self.selectedImageView.image = image
            })
        case catagoryCollectionView:
            // Deselect all cells
            for i in collectionView.indexPathsForSelectedItems! {
                dump(collectionView.indexPathsForSelectedItems!)
                collectionView.deselectItem(at: i, animated: true)
                let deselectedCell = collectionView.cellForItem(at: indexPath) as! CatagoryButtonInUploadCollectionViewCell
                deselectedCell.catagoryLabel.backgroundColor = JashColors.primaryColor
                deselectedCell.catagoryLabel.textColor = JashColors.textAndIconColor
            }
            // Select cell and change label color
            let selectedCell = collectionView.cellForItem(at: indexPath) as! CatagoryButtonInUploadCollectionViewCell
            selectedCell.catagoryLabel.backgroundColor = JashColors.accentColor
            selectedCell.catagoryLabel.textColor = JashColors.textAndIconColor
        default:
            print(catagoryTitlesArr[indexPath.row])
        }
    }
    
    // MARK: - Setup View Hierarchy
    private func setupViewHierarchy() {
        //self.view.addSubview(navigationBar)
        
        self.view.addSubview(containerView)
        self.view.addSubview(titleAndCatagoryContainerView)
        
        self.titleAndCatagoryContainerView.addSubview(self.titleTextfield)
        self.titleAndCatagoryContainerView.addSubview(self.catagoryContainerView)
        
        self.containerView.addSubview(self.titleAndCatagoryContainerView)
        self.containerView.addSubview(self.selectedImageView)
        self.containerView.addSubview(self.imagePickerContainerView)
        
        self.imagePickerContainerView.addSubview(self.imagePickerCollectionView)
        self.catagoryContainerView.addSubview(self.catagoryCollectionView)
    }
    
    // MARK: - Configure Constraints
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        //navigationBar
//        navigationBar.snp.makeConstraints { (bar) in
//           // bar.top.equalTo(self.topLayoutGuide.snp.bottom)
//            bar.leading.trailing.equalToSuperview()
//            bar.leading.top.trailing.equalToSuperview()
//        }
//        
        //containerView
        containerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        
        //titleAndCatagoryContainerView's Subviews

        titleTextfield.snp.makeConstraints { (textField) in
            textField.top.equalToSuperview().offset(16)
            textField.centerX.equalToSuperview()
//            textField.trailing.equalToSuperview().inset(16)
        }
        titleTextfield.underLine(placeHolder: "Title")
        //catagoryCollectionView
        catagoryContainerView.snp.makeConstraints { (collectionView) in
            collectionView.leading.trailing.equalToSuperview()
            collectionView.top.equalTo(self.titleTextfield.snp.bottom).offset(10)
            collectionView.bottom.equalToSuperview().inset(4)
            collectionView.height.equalTo(36.0)
        }
        
        //ContainerView's SubView
        //titleAndCatagoryContainerView
        titleAndCatagoryContainerView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.top.trailing.equalToSuperview()
        }
        catagoryCollectionView.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalToSuperview()
        }
        
        //selectedImageView
        selectedImageView.snp.makeConstraints { (view) in
            view.top.equalTo(self.titleAndCatagoryContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.frame.width)
        }
        
        //imagePickerCollectionView
        imagePickerContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.selectedImageView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        imagePickerCollectionView.snp.makeConstraints { (view) in
            view.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    //MARK: - lazy vars
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = JashColors.primaryColor
        return view
    }()
    
    lazy var titleAndCatagoryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = JashColors.primaryColor
        return view
    }()
    
    lazy var titleTextfield: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    lazy var catagoryContainerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    lazy var catagoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 150, height: 36)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.backgroundColor = JashColors.primaryColor
        cView.allowsMultipleSelection = false
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.backgroundColor = UIColor.orange
        return imageView
    }()
    
    lazy var imagePickerContainerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    lazy var imagePickerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.showsHorizontalScrollIndicator = false
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
}
