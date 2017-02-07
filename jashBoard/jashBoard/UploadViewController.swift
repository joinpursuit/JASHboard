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
    //MARK: - Properties
    var catagoryTitlesArr: [String] = ["Animals", "Beach Days" ,"Cars", "Flowers & Plants"]
    var photoAssetsArr: [PHAsset] = []
    let manager = PHImageManager.default()
    
    var selectedCategory: String!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UPLOAD"
        self.view.backgroundColor = .purple
        
        setupViewHierarchy()
        configureConstraints()
        
        //Register Cells
        self.imagePickerCollectionView.register(PhotoInUploadCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInUploadCollectionViewCell.identifier)
        self.categoryCollectionView.register(CatagoryButtonInUploadCollectionViewCell.self, forCellWithReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier)
        
        //Setup Navigation Bar
        let navItem = UINavigationItem(title: "UPLOAD")
        navItem.rightBarButtonItem = uploadBarButton
        self.navigationBar.items = [navItem]
        
        //Populate array with assets for imagePickerCollectionView
        fetchPhotos()
        
        //Firebase: if user is anonymous (no email) they will be restricted from uploading pictures.
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
        //need to create a unique picture ID for for DB and storage each time we upload an image.
        guard let category = self.selectedCategory else {
            let alertController = UIAlertController(title: "Wait a minute!", message: "Select a category before uploading.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okay)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //update real time database
        let databaseReference = FIRDatabase.database().reference().child("\(category)")
        let newItemReference = databaseReference.childByAutoId()
        let id = newItemReference.key
        
        let newItemDetails: [String : AnyObject] = [
            "upvotes" : 0 as AnyObject,
            "downvotes" : 0 as AnyObject
        ]
        newItemReference.setValue(newItemDetails)
        
        //update storage
        let storageReference = FIRStorage.storage().reference().child("\(category)").child("\(id)")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        if let image = self.selectedImageView.image,
            let imageData = UIImageJPEGRepresentation(image, 0.8) {
            
            let uploadTask = storageReference.put(imageData, metadata: uploadMetadata) { (metadata: FIRStorageMetadata?, error: Error?) in
                if error != nil {
                    print("Encountered an error: \(error?.localizedDescription)")
                }
                else {
                    print("Upload complete: \(metadata)")
                    print("HERE'S YOUR DOWNLOAD URL: \(metadata?.downloadURL())")
                }
            }
        }
        //Update the progress bar
//        uploadTask.observe(.progress) { (snapshot: FIRStorageTaskSnapshot) in
//            guard let progress = snapshot.progress else { return }
//            
//            self.progressView.progress = Float(progress.fractionCompleted)
//        }
    }

    func fetchPhotos() {
        //sorting results by creation date
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let allPhotosResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
        //get assets from PHFetchResult<PHAsset> object and populate the array we populate the collectionview with.
        allPhotosResult.enumerateObjects({ self.photoAssetsArr.append($0.0) })
    }
    
    // MARK: - CollectionViewDelegate & CollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case imagePickerCollectionView:
            return self.photoAssetsArr.count
        case categoryCollectionView:
            return self.catagoryTitlesArr.count
        default:
            return self.catagoryTitlesArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case imagePickerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInUploadCollectionViewCell.identifier, for: indexPath) as! PhotoInUploadCollectionViewCell
            
            let photo = photoAssetsArr[indexPath.row]
            
            manager.requestImage(for: photo, targetSize: cell.imageView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                cell.imageView.image = image
            })
            
            cell.backgroundColor = .white
            return cell
        case categoryCollectionView:
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
        case categoryCollectionView:
            print(catagoryTitlesArr[indexPath.row])
            self.selectedCategory = catagoryTitlesArr[indexPath.row]
        default:
            print(catagoryTitlesArr[indexPath.row])
        }
    }
    
    // MARK: - Setup View Hierarchy
    private func setupViewHierarchy() {
        self.view.addSubview(navigationBar)
        
        self.view.addSubview(containerView)
        self.view.addSubview(titleAndCatagoryContainerView)
        
        self.titleAndCatagoryContainerView.addSubview(self.titleTextfield)
        self.titleAndCatagoryContainerView.addSubview(self.catagoryContainerView)
        
        self.containerView.addSubview(self.titleAndCatagoryContainerView)
        self.containerView.addSubview(self.selectedImageView)
        self.containerView.addSubview(self.imagePickerView)
        
        self.imagePickerView.addSubview(self.imagePickerCollectionView)
        self.catagoryContainerView.addSubview(self.categoryCollectionView)
    }
    
    // MARK: - Configure Constraints
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        //navigationBar
        navigationBar.snp.makeConstraints { (bar) in
            bar.top.equalTo(self.topLayoutGuide.snp.bottom)
            bar.leading.trailing.equalToSuperview()
            //bar.leading.top.trailing.equalToSuperview()
        }
        
        //containerView
        containerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.navigationBar.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        
        //titleAndCatagoryContainerView's Subviews
        //titleTextField
        titleTextfield.snp.makeConstraints { (textField) in
            textField.top.equalToSuperview().offset(16)
            textField.leading.equalToSuperview().offset(16)
            textField.trailing.equalToSuperview().inset(16)
        }
        //catagoryCollectionView
        catagoryContainerView.snp.makeConstraints { (collectionView) in
            collectionView.leading.trailing.equalToSuperview()
            collectionView.top.equalTo(self.titleTextfield.snp.bottom).offset(8)
            collectionView.bottom.equalToSuperview().offset(8)
            collectionView.height.equalTo(52.0)
        }
        
        //ContainerView's SubView
        //titleAndCatagoryContainerView
        titleAndCatagoryContainerView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.top.trailing.equalToSuperview()
        }
        categoryCollectionView.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalToSuperview()
        }
        
        //selectedImageView
        selectedImageView.snp.makeConstraints { (view) in
            view.top.equalTo(self.titleAndCatagoryContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.frame.width)
        }
        
        //imagePickerCollectionView
        imagePickerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.selectedImageView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        imagePickerCollectionView.snp.makeConstraints { (view) in
            view.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    //MARK: - lazy vars
    lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.backgroundColor = UIColor.darkGray
        return navBar
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    lazy var titleAndCatagoryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    lazy var titleTextfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "title"
        textField.backgroundColor = UIColor.purple
        return textField
    }()
    
    lazy var catagoryContainerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.brown
        return collectionView
    }()
    
    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: 130, height: 60)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.backgroundColor = UIColor.orange
        
        //aspect Fit/ Fill?
        
        return imageView
    }()
    
    lazy var imagePickerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.red
        return collectionView
    }()
    
    lazy var imagePickerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    lazy var uploadBarButton: UIBarButtonItem =  {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "up_arrow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadPhotoToFireBaseButtonPressed(_:)))
        return button
    }()
}
