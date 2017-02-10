//
//  RegisterNewUserViewController.swift
//  jashBoard
//
//  Created by Ana Ma on 2/8/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import AVFoundation
import AVKit
import MobileCoreServices

class RegisterNewUserViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var signInUser: FIRUser?
    
    var capturedImages: [UIImage]! = []
    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = JashColors.primaryColor
        setupViewHierarchy()
        configureConstraints()
        setTextFieldDelegates()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //Set placeholder for textField
        self.userFirstNameTextField.underLine(placeHolder: "first name")
        self.userLastNameTextField.underLine(placeHolder: "last name")
        self.userEmailTextField.underLine(placeHolder: "email")
        self.passwordTextField.underLine(placeHolder: "password")
        
    }
    
    override func viewDidLayoutSubviews() {
        //Add animation to profilePictureImageView
        let pulse = Pulsing(numberOfPalses: 100, radius: 150, position: self.profilePictureImageView.center)
        pulse.animationDuration = 1
        
        self.view.layer.insertSublayer(pulse, below: profilePictureImageView.layer)
    }
    
    // MARK: - PhotoPicker Methods
    func editButtonTapped(_ sender: UIButton) {
        print("Edit Button Tapped")
        let editProfileAlertController = UIAlertController(title: "Edit Profile Image", message: nil, preferredStyle: .alert)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let oneAction = UIAlertAction(title: "Take a New Profile Picture", style: .default) { _ in
                print("Action One Tapped")
                self.showImagePickerForCamera(sender)
            }
            editProfileAlertController.addAction(oneAction)
        }

        let twoAction = UIAlertAction(title: "Select Profile Picture", style: .default) { _ in
            print("Action Two Tapped")
            self.showImagePickerForSourceType(sourceType: .photoLibrary, fromButton: sender)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel Tapped")
        }
        
        editProfileAlertController.addAction(twoAction)
        editProfileAlertController.addAction(cancelAction)
        self.present(editProfileAlertController, animated: true, completion: nil)
    }
    
    func showImagePickerForCamera(_ sender: UIButton) {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .denied {
            
        }
        else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted: Bool) in
                if (granted) {
                    self.showImagePickerForSourceType(sourceType: .camera, fromButton: sender)
                }
            }
        }
        else {
            self.showImagePickerForSourceType(sourceType: .camera, fromButton: sender)
        }
    }

    
    private func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType, fromButton button: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
        
        self.imagePickerController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.capturedImages.append(image)
        }
        self.finishAndUpdate()
    }
    
    private func finishAndUpdate() {
        self.dismiss(animated: true, completion: nil)
        if self.capturedImages.count > 0 {
            if self.capturedImages.count == 1 {
                self.profilePictureImageView.image = self.capturedImages[0]
            }
            else {
                self.profilePictureImageView.animationImages = self.capturedImages
                self.profilePictureImageView.animationDuration = 5.0
                self.profilePictureImageView.animationRepeatCount = 0
                self.profilePictureImageView.startAnimating()
            }
        }
        self.capturedImages.removeAll()
    }
    
    // MARK: - Tab Gesture Selector
    func dismissKeyboard() {
        self.userFirstNameTextField.resignFirstResponder()
        self.userLastNameTextField.resignFirstResponder()
        self.userEmailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    // MARK: - TextField Delegate Methods
    func setTextFieldDelegates() {
        userFirstNameTextField.delegate = self
        userLastNameTextField.delegate = self
        userEmailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! || textField.text == "" {
            switch textField {
            case userFirstNameTextField:
                textField.underLine(placeHolder: "first name")
            case userLastNameTextField:
                textField.underLine(placeHolder: "last name")
            case userEmailTextField:
                textField.underLine(placeHolder: "email")
            case passwordTextField:
                textField.underLine(placeHolder: "password")
            default:
                return true
            }
        }
        textField.shake()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    private func setupViewHierarchy() {
        self.view.addSubview(profilePictureImageView)
        self.view.addSubview(editProfilePictureButton)
        self.view.addSubview(textFieldContainerView)
        self.textFieldContainerView.addSubview(userFirstNameTextField)
        self.textFieldContainerView.addSubview(userLastNameTextField)
        self.textFieldContainerView.addSubview(userEmailTextField)
        self.textFieldContainerView.addSubview(passwordTextField)
        self.view.addSubview(registerButton)
    }
    
    private func configureConstraints() {
        let profileSize = CGSize(width: 150, height: 150)
        
        profilePictureImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            view.size.equalTo(profileSize)
        }
        
        editProfilePictureButton.snp.makeConstraints{ (button) in
            button.centerX.equalToSuperview()
            button.top.equalTo(self.profilePictureImageView.snp.bottom).offset(8)
            button.width.equalTo(JashButton.defaultSize.width)
        }
        
        textFieldContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.editProfilePictureButton.snp.bottom).offset(16)
            view.leading.equalToSuperview().inset(16)
            view.trailing.bottom.equalToSuperview().offset(-16)
        }
        
        userFirstNameTextField.snp.makeConstraints { (textField) in
            textField.top.leading.trailing.equalToSuperview()
        }
        
        userLastNameTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(userFirstNameTextField.snp.bottom).offset(8)
            textField.leading.trailing.equalToSuperview()
        }
        
        userEmailTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(userLastNameTextField.snp.bottom).offset(8)
            textField.leading.trailing.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(userEmailTextField.snp.bottom).offset(8)
            textField.leading.trailing.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { (button) in
            button.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-16)
            button.centerX.equalTo(self.view.snp.centerX)
            button.width.equalTo(JashButton.defaultSize.width)
            //button.height.equalTo(JashButton.defaultSize.height)
        }
    }
    
    // MARK: - Actions
    
    func registerButtonDidTapped(_ sender: UIButton) {
        guard let userName = userEmailTextField.text,
            let password = passwordTextField.text,
            let firstName = userFirstNameTextField.text,
            firstName != "",
            let lastName = userLastNameTextField.text,
            lastName != "" else { return }
        self.registerButton.isEnabled = false
        FIRAuth.auth()?.createUser(withEmail: userName, password: password, completion: { (user: FIRUser?, error: Error?) in
            self.registerButton.isEnabled = true
            if error != nil {
                let errorAlertController = UIAlertController(title: "Registering Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
            }
            guard let validUser = user else { return }
            guard let newUser = FIRAuth.auth()?.currentUser else { return }
            
            //creating users for db
            let uid = newUser.uid
            let databaseReference = FIRDatabase.database().reference().child("USERS/\(uid)")
            
            let info: [String: AnyObject] = [
                "name" : "\(firstName) \(lastName)" as AnyObject,
                "email" : userName as AnyObject
                ]
            
            databaseReference.setValue(info)
            // TO DO: ADD IN PROFILE PICTURE
            let storageReference = FIRStorage.storage().reference().child("ProfilePictures").child("\(uid)")
            
            let uploadMetadata = FIRStorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            
            if let image = self.profilePictureImageView.image,
                let imageData = UIImageJPEGRepresentation(image, 0.8) {
                
                //upload image data to Storage reference
                let uploadTask = storageReference.put(imageData, metadata: uploadMetadata) { (metadata: FIRStorageMetadata?, error: Error?) in
                    
                    DispatchQueue.main.async {
                        print("Encountered an error: \(error?.localizedDescription)")
                        self.signInUser = validUser
                        self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
                    }
                    
                }
            }
            
            self.signInUser = validUser
            self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
        })
    }
    
    func imageTapped(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.profilePictureImageView.image = image
//        }
//        dismiss(animated: true)
//    }
    
    // MARK: - Lazy Vars
    lazy var profilePictureImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = JashColors.accentColor.cgColor
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.frame.size = CGSize(width: 150.0, height: 150.0)
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var textFieldContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var userFirstNameTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = JashColors.accentColor
        textField.textColor = JashColors.textAndIconColor
        textField.autocorrectionType = .no
        textField.underLine(placeHolder: "first name")
        return textField
    }()
    
    lazy var userLastNameTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = JashColors.accentColor
        textField.textColor = JashColors.textAndIconColor
        textField.autocorrectionType = .no
        textField.underLine(placeHolder: "last name")
        return textField
    }()
    
    lazy var userEmailTextField: UITextField = {
       let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.tintColor = JashColors.accentColor
        textField.textColor = JashColors.textAndIconColor
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.underLine(placeHolder: "email")
       return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = JashColors.accentColor
        textField.textColor = JashColors.textAndIconColor
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.underLine(placeHolder: "password")
        return textField
    }()
    
    lazy var selectProfilePictureFromLibraryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Profile Picture", for: .normal)
        return button
    }()
    
    lazy var takeProfilePictureFromCameraButton: UIButton = {
       let button = UIButton()
        button.setTitle("Take New Profile Picture", for: .normal)
        return button
    }()
    
    lazy var editProfilePictureButton: UIButton = {
        let button = JashButton(title: "Edit Profile Picture")
        button.addTarget(self, action: #selector(editButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
        let button = JashButton(title: "Register")
        button.addTarget(self, action: #selector(registerButtonDidTapped), for: UIControlEvents.touchUpInside)
        return button
    }()

}
