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

class RegisterNewUserViewController: UIViewController {

    var signInUser: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = JashColors.primaryColor
        
        setupViewHierarchy()
        configureConstraints()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Tab Gesture Selector
    func dismissKeyboard() {
        self.userFirstNameTextField.resignFirstResponder()
        self.userLastNameTextField.resignFirstResponder()
        self.userEmailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }

    private func setupViewHierarchy() {
        self.view.addSubview(profilePictureImageView)
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
        
        textFieldContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.profilePictureImageView.snp.bottom).offset(16)
            view.trailing.equalToSuperview().offset(16)
            view.leading.bottom.equalToSuperview().inset(16)
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
            button.height.equalTo(JashButton.defaultSize.height)
        }
    }
    
    func registerButtonDidTapped(_ sender: UIButton) {
        guard let userName = userEmailTextField.text,
            let password = passwordTextField.text else { return }
        self.registerButton.isEnabled = false
        FIRAuth.auth()?.createUser(withEmail: userName, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                let errorAlertController = UIAlertController(title: "Registering Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
            }
            guard let validUser = user else { return }
            self.signInUser = validUser
            self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
        })
    }
    
    // MARK: - Lazy Vars
    lazy var profilePictureImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 0.5
        imageView.frame.size = CGSize(width: 150.0, height: 150.0)
        return imageView
    }()
    
    lazy var textFieldContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var userFirstNameTextField: UITextField = {
        let textField = UITextField()
        textField.underLine(placeHolder: "first name")
        textField.textColor = .white
        textField.tintColor = .clear
        return textField
    }()
    
    lazy var userLastNameTextField: UITextField = {
        let textField = UITextField()
        textField.underLine(placeHolder: "last Name")
        textField.textColor = .white
        textField.tintColor = .clear
        return textField
    }()
    
    lazy var userEmailTextField: UITextField = {
       let textField = UITextField()
        textField.underLine(placeHolder: "email")
        textField.keyboardType = .emailAddress
        textField.textColor = .white
        textField.tintColor = .clear
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
       return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.underLine(placeHolder: "password")
        textField.textColor = .white
        textField.tintColor = .clear
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var registerButton: JashButton = {
        let button = JashButton()
        button.setTitle("REGISTER", for: UIControlState.normal)
        button.addTarget(self, action: #selector(registerButtonDidTapped), for: UIControlEvents.touchUpInside)
        return button
    }()

}
