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

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

    //MARK: - Properties
    var catagoryTitlesArr: [String] = ["ANIMALS", "BEACH DAYS" ,"CARS", "FLOWERS & PLANTS"]
    var photoAssetsArr: [PHAsset] = []
    let manager = PHImageManager.default()
    var selectedCategory: String!
    var selectedImage: UIImage!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UPLOAD"
        self.tabBarItem.title = ""
        self.view.backgroundColor = JashColors.darkPrimaryColor
        
        setupViewHierarchy()
        configureConstraints()
        
        // Textfield Delegate
        titleTextfield.delegate = self
        
        //Register Cells
        self.imagePickerCollectionView.register(PhotoInUploadCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInUploadCollectionViewCell.identifier)
        self.categoryCollectionView.register(CatagoryTapInUploadCollectionViewCell.self, forCellWithReuseIdentifier: CatagoryTapInUploadCollectionViewCell.identifier)
        self.imageSelectedWithPagingCollectionView.register(ImageSelectedInUploadCollectionViewCell.self, forCellWithReuseIdentifier: ImageSelectedInUploadCollectionViewCell.identifier)
        
        //Setup Navigation Bar
        self.navigationItem.rightBarButtonItem = uploadBarButton

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
        
        //Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.imageSelectedWithPagingCollectionView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Tab Gesture Selector
    func dismissKeyboard() {
        self.titleTextfield.resignFirstResponder()
    }
    
    // MARK: - Functions
    func uploadPhotoToFireBaseButtonPressed(_ sender: UIBarButtonItem) {
        print("uploadPhotoToFireBaseButtonPressed")
        
        guard let category = self.selectedCategory,
            let titleText = self.titleTextfield.text,
            titleText.characters.count > 0
            else {
                let alertController = UIAlertController(title: "Wait a minute!", message: "Select a category and title before uploading.", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okay)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        
        //update references in database
        let databaseReference = FIRDatabase.database().reference().child("\(category)")
        let newItemReference = databaseReference.childByAutoId()
        let imageID = newItemReference.key
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let userDBReference = FIRDatabase.database().reference().child("USERS").child("\(uid)/uploads/\(imageID)")
        print(userDBReference)
        
        let votesDict: [String : AnyObject] = [
            "upvotes" : 0 as AnyObject,
            "downvotes" : 0 as AnyObject,
            "title" : titleText as AnyObject
        ]
        
        let userInfo: [String: AnyObject] = [
            "category" : category as AnyObject,
            "title" : titleText as AnyObject
            
        ]
        newItemReference.setValue(votesDict)
        userDBReference.setValue(userInfo)
        
        //update storage
        let storageReference = FIRStorage.storage().reference().child("\(category)").child("\(imageID)")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        if let image = self.selectedImage,
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
            
        case imageSelectedWithPagingCollectionView:
            return self.photoAssetsArr.count
            
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
            cell.backgroundColor = .clear
            return cell
            
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatagoryTapInUploadCollectionViewCell.identifier, for: indexPath) as! CatagoryTapInUploadCollectionViewCell
            let catagoryTitle = catagoryTitlesArr[indexPath.row]
            cell.catagoryLabel.text = catagoryTitle
            return cell
            
        case imageSelectedWithPagingCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSelectedInUploadCollectionViewCell.identifier, for: indexPath) as! ImageSelectedInUploadCollectionViewCell
            let photo = photoAssetsArr[indexPath.row]
            manager.requestImage(for: photo, targetSize: cell.imageView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                cell.imageView.image = image
            })
            cell.backgroundColor = UIColor.clear
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatagoryTapInUploadCollectionViewCell.identifier, for: indexPath) as! CatagoryTapInUploadCollectionViewCell
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
            self.imageSelectedWithPagingCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            manager.requestImage(for: photo, targetSize: imageSelectedWithPagingCollectionView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                //To Do: Need to update some logic
                self.selectedImage = image
            })
        case categoryCollectionView:
            print(catagoryTitlesArr[indexPath.row])
            self.selectedCategory = catagoryTitlesArr[indexPath.row]
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as! CatagoryTapInUploadCollectionViewCell

            // Reset not selected cells
            for cell in collectionView.visibleCells {
                if let categoryCell = cell as?  CatagoryTapInUploadCollectionViewCell, categoryCell != selectedCell {
                    categoryCell.catagoryLabel.backgroundColor = JashColors.primaryColor
                    categoryCell.catagoryLabel.textColor = JashColors.textAndIconColor
                }
            }
            
            // Update selected cell's label text color and background color
            selectedCell.catagoryLabel.backgroundColor = JashColors.accentColor
            selectedCell.catagoryLabel.textColor = JashColors.textAndIconColor
            self.catagoryContainerView.reloadInputViews()
        
        case imageSelectedWithPagingCollectionView:
            print(photoAssetsArr[indexPath.row])
            
        default:
            print(catagoryTitlesArr[indexPath.row])
        }
    }
    
    // MARK: - Scroll View Delegate Methods
    //http://stackoverflow.com/questions/33855945/uicollectionview-to-snap-onto-a-cell-when-scrolling-horizontally
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView {
        case imageSelectedWithPagingCollectionView:
            snapToNearestCell(scrollView)
        default:
            print()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        switch scrollView {
        case imageSelectedWithPagingCollectionView:
            snapToNearestCell(scrollView)
        default:
            print()
        }
    }
    
    func snapToNearestCell(_ scrollView: UIScrollView) {
        let visibleCenterPositionOfScrollView: CGFloat = scrollView.contentOffset.x + self.imageSelectedWithPagingCollectionView.bounds.size.width
        var closestCellIndex: Int?
        for (index, item) in photoAssetsArr.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = imageSelectedWithPagingCollectionView.cellForItem(at: indexPath) as UICollectionViewCell? {
                let cellWidth = cell.bounds.size.width
                let cellCenter = cell.frame.origin.x + cellWidth / 2
                if (visibleCenterPositionOfScrollView - cellCenter) <= (cellWidth) {
                    closestCellIndex = photoAssetsArr.index(of: item)
                }
            }
        }
        if (closestCellIndex != nil) {
            let indexPath = IndexPath(item: closestCellIndex!, section: 0)
            print(photoAssetsArr[indexPath.row])
            self.imagePickerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            let photo = photoAssetsArr[indexPath.row]
            manager.requestImage(for: photo, targetSize: imageSelectedWithPagingCollectionView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (image:  UIImage?, _) in
                self.selectedImage = image
            })
        }
    }

    // MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! || textField.text == "" {
            textField.underLine(placeHolder: "Title")
        }
        
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Setup View Hierarchy
    private func setupViewHierarchy() {
        
        self.view.addSubview(containerView)
        self.view.addSubview(titleAndCatagoryContainerView)
        
        self.titleAndCatagoryContainerView.addSubview(self.titleTextfield)
        self.titleAndCatagoryContainerView.addSubview(self.catagoryContainerView)
        
        self.containerView.addSubview(self.titleAndCatagoryContainerView)
        self.containerView.addSubview(self.imageSelectedWithPagingCollectionView)
        self.containerView.addSubview(self.imagePickerContainerView)
        

        self.imagePickerContainerView.addSubview(self.imagePickerCollectionView)
        self.catagoryContainerView.addSubview(self.categoryCollectionView)
    }
    
    // MARK: - Configure Constraints
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
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
        categoryCollectionView.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalToSuperview()
        }
        
        //imageCollectionViewWithPagingContainerView
        imageSelectedWithPagingCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(self.titleAndCatagoryContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.frame.width)
        }
        
        //imagePickerCollectionView
        imagePickerContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.imageSelectedWithPagingCollectionView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        imagePickerCollectionView.snp.makeConstraints { (view) in
            view.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    //MARK: - lazy vars
    // Navigation Bar and Item
    lazy var uploadBarButton: UIBarButtonItem =  {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "up_arrow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadPhotoToFireBaseButtonPressed(_:)))
        return button
    }()
    
    // Container View Of all subViews
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = JashColors.primaryColor
        return view
    }()
    
    // Title And Catagory
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
    
    // Catagory Collection View
    lazy var categoryCollectionView: UICollectionView = {
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
    
    // ImageSelected Collection View
    lazy var imageSelectedWithPagingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.isPagingEnabled = true
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    // Image Picker Container View
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
        cView.bounces = false
        cView.showsHorizontalScrollIndicator = false
        cView.isPagingEnabled = true
        cView.allowsMultipleSelection = false
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
}
