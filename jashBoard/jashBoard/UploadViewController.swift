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
            cell.backgroundColor = .white
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
            cell.backgroundColor = UIColor.red
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

            // Deselect all cells
            for i in collectionView.indexPathsForSelectedItems! {
                dump(collectionView.indexPathsForSelectedItems!)
                collectionView.deselectItem(at: i, animated: true)
                let deselectedCell = collectionView.cellForItem(at: indexPath) as! CatagoryTapInUploadCollectionViewCell
                deselectedCell.catagoryLabel.backgroundColor = JashColors.primaryColor
                deselectedCell.catagoryLabel.textColor = JashColors.textAndIconColor
            }
            // Select cell and change label color
            let selectedCell = collectionView.cellForItem(at: indexPath) as! CatagoryTapInUploadCollectionViewCell
            selectedCell.catagoryLabel.backgroundColor = JashColors.accentColor
            selectedCell.catagoryLabel.textColor = JashColors.textAndIconColor
        
        case imageSelectedWithPagingCollectionView:
            print(photoAssetsArr[indexPath.row])
            
        default:
            print(catagoryTitlesArr[indexPath.row])
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch collectionView {
//        case imageSelectedWithPagingCollectionView:
//            return CGSize(width: self.imageSelectedWithPagingCollectionView.frame.size.width, height: self.imageSelectedWithPagingCollectionView.frame.size.height)
//        case imagePickerCollectionView:
//            return CGSize(width: self.imagePickerCollectionView.frame.width, height: self.imagePickerCollectionView.frame.width)
//        default:
//            return CGSize(width: self.imageSelectedWithPagingCollectionView.frame.size.width, height: self.imageSelectedWithPagingCollectionView.frame.size.height)
//        }
//        
//    }
    
    //http://stackoverflow.com/questions/33855945/uicollectionview-to-snap-onto-a-cell-when-scrolling-horizontally
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView {
        case imageSelectedWithPagingCollectionView:
            snapToNearestCell(scrollView)
            print()
        default:
            print()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //switch scrollView {
        //case imageSelectedWithPagingCollectionView:
        //    snapToNearestCell(scrollView)
        //    print()
        //default:
        //    print()
        //}
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        switch scrollView {
        case imageSelectedWithPagingCollectionView:
            snapToNearestCell(scrollView)
            print()
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
            self.imageSelectedWithPagingCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            print(photoAssetsArr[indexPath.row])
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
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Setup View Hierarchy
    private func setupViewHierarchy() {
        //self.view.addSubview(navigationBar)
        
        self.view.addSubview(containerView)
        self.view.addSubview(titleAndCatagoryContainerView)
        
        self.titleAndCatagoryContainerView.addSubview(self.titleTextfield)
        self.titleAndCatagoryContainerView.addSubview(self.catagoryContainerView)
        
        self.containerView.addSubview(self.titleAndCatagoryContainerView)
        //self.containerView.addSubview(self.selectedImageView)
        self.containerView.addSubview(self.imageSelectedWithPagingCollectionView)
        self.containerView.addSubview(self.imagePickerContainerView)
        

        self.imagePickerContainerView.addSubview(self.imagePickerCollectionView)
        self.catagoryContainerView.addSubview(self.categoryCollectionView)
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
        categoryCollectionView.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalToSuperview()
        }
        
        //imageCollectionViewWithPagingContainerView
        imageSelectedWithPagingCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(self.titleAndCatagoryContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.frame.width)
        }
        
        //selectedImageView
//        selectedImageView.snp.makeConstraints { (view) in
//            view.top.equalTo(self.titleAndCatagoryContainerView.snp.bottom)
//            view.leading.trailing.equalToSuperview()
//            view.height.equalTo(self.view.frame.width)
//        }
        
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
    lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.backgroundColor = JashColors.primaryColor
        return navBar
    }()
    
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
    
//    lazy var selectedImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = #imageLiteral(resourceName: "default-placeholder")
//        imageView.backgroundColor = UIColor.orange
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
    
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
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
}
