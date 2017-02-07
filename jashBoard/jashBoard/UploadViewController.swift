//
//  UploadViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import SnapKit

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var photosArr: [UIImage] = [#imageLiteral(resourceName: "default-placeholder"),#imageLiteral(resourceName: "logo")]
    var buttonTitlesArr: [String] = ["Animals", "Cars"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UPLOAD"
        self.view.backgroundColor = .purple
        
        setupViewHierarchy()
        configureConstraints()
        
        //Register Cells
        self.imagePickerCollectionView.register(PhotoInUploadCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInUploadCollectionViewCell.identifier)
        self.catagoryCollectionView.register(CatagoryButtonInUploadCollectionViewCell.self, forCellWithReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier)
        
        let navItem = UINavigationItem(title: "UPLOAD")
        let uploadBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "up_arrow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadPhotoToFireBaseButtonPressed))
        navItem.rightBarButtonItem = uploadBarButton
        self.navigationBar.items = [navItem]
    }
    
    // MARK: - Selector Functions
    func uploadPhotoToFireBaseButtonPressed(_ sender: UIBarButtonItem) {
        print("uploadPhotoToFireBaseButtonPressed")
    }
    
    // MARK: - CollectionViewDelegate & CollectionView Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case imagePickerCollectionView:
            return self.photosArr.count
        default:
            return self.buttonTitlesArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case imagePickerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInUploadCollectionViewCell.identifier, for: indexPath) as! PhotoInUploadCollectionViewCell
            
            let photo = photosArr[indexPath.row]
            
            cell.imageView.image = photo
            cell.backgroundColor = .white
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatagoryButtonInUploadCollectionViewCell.identifier, for: indexPath) as! CatagoryButtonInUploadCollectionViewCell
            
            let buttonTitle = buttonTitlesArr[indexPath.row]
            cell.catagoryButton.setTitle(buttonTitle, for: UIControlState.normal)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case imagePickerCollectionView:
            print(photosArr[indexPath.row])
        default:
            print(buttonTitlesArr[indexPath.row])
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
        self.catagoryContainerView.addSubview(self.catagoryCollectionView)
        
    }
    
    // MARK: - Configure Constraints
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        //navigationBar
        navigationBar.snp.makeConstraints { (bar) in
            bar.leading.top.trailing.equalToSuperview()
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
    
    lazy var catagoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        layout.itemSize = CGSize(width: 110, height: 120)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
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
    
    lazy var imagePickerView: UIView = {
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.red
        return collectionView
    }()
    
    lazy var imagePickerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        layout.itemSize = CGSize(width: 110, height: 120)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        let cView = UICollectionView(frame: self.catagoryContainerView.frame, collectionViewLayout: layout)
        cView.collectionViewLayout = layout
        cView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
}
