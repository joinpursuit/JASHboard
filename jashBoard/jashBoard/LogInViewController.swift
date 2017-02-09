//
//  LogInViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController, UITextFieldDelegate {

    var signInUser: FIRUser?
    let testButton: UIButton = UIButton(type: UIButtonType.roundedRect)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOGIN/REGISTER"
        self.tabBarItem.title = ""
        self.view.backgroundColor = JashColors.primaryColor

        setupViewHierarchy()
        configureConstraints()
//        loginAnonymously() // Refactored into App Delegate
        
        // Textfield Delegate
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //FirAuth
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user?.email == nil {
                self.loginButton.isEnabled = true
                self.loginButton.isUserInteractionEnabled = true
                self.registerButton.isEnabled = true
                self.registerButton.isUserInteractionEnabled = true
            } else {
                self.loginButton.isEnabled = false
                self.loginButton.isUserInteractionEnabled = false
                self.registerButton.isEnabled = false
                self.registerButton.isUserInteractionEnabled = false
            }
        })
    }
    
    // MARK: Tab Gesture Selector
    func dismissKeyboard() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(logo)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(registerButton)
        self.view.addSubview(testButton)
        loginButton.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister(sender:)), for: .touchUpInside)
        testButton.addTarget(self, action: #selector(showProgress), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        // logo
        logo.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16.0)
            view.centerX.equalToSuperview()
            view.size.equalTo(CGSize(width: 150, height: 150))
        }
        
        // username
        usernameTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(logo.snp.bottom).offset(16)
            textField.centerX.equalToSuperview()
        }
        usernameTextField.underLine(placeHolder: "Username")
   
        // password
        passwordTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(usernameTextField.snp.bottom).offset(16)
            textField.centerX.equalToSuperview()
        }

        testButton.setTitle("PROGRESS!!", for: .normal)
        testButton.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
        }

        passwordTextField.underLine(placeHolder: "password")
        
        // register button
        registerButton.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(16.0)
            view.centerX.equalTo(self.view.snp.centerX)
            view.width.equalTo(JashButton.defaultSize.width)
        }
        
        // login button
        loginButton.snp.makeConstraints { (view) in
            view.bottom.equalTo(registerButton.snp.top).offset(-8.0)
            view.centerX.equalTo(self.view.snp.centerX)
            view.width.equalTo(JashButton.defaultSize.width)
        }
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! || textField.text == "" {
            if textField == usernameTextField {
                textField.underLine(placeHolder: "Username")
            } else {
                textField.underLine(placeHolder: "Password")
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Actions
    
    internal func didTapLogin(sender: UIButton) {
        guard let userName = usernameTextField.text,
            let password = passwordTextField.text else { return }
        self.loginButton.isEnabled = false
        FIRAuth.auth()?.signIn(withEmail: userName, password: password, completion: { (user: FIRUser?, error: Error?) in
            self.loginButton.isEnabled = true
            if error != nil {
                //print("Error present when login button is pressed")
                let errorAlertController = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
            }
            guard let validUser = user else { return }
            self.signInUser = validUser
            self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
        })
    }
    
    internal func didTapRegister(sender: UIButton) {
        let registerNewUserViewController = RegisterNewUserViewController()
        registerNewUserViewController.userEmailTextField.text = self.usernameTextField.text
        registerNewUserViewController.passwordTextField.text = self.passwordTextField.text
        self.navigationController?.pushViewController(registerNewUserViewController, animated: true)
    }

    // Refactored to be in app delegate
//    static func loginAnonymously() {
//        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
//            if error != nil {
//                print("Error attempting to long in anonymously: \(error!)")
//            }
//            if user != nil {
//                print("Signed in anonymously!")
//                // self.signInUser = user
//            }
//        })
//    }
    

    // MARK: - Navigation
    
    func showProgress(){
        let alert = JashProgressViewController()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true, completion: nil)
    }

    func showUserHomeVC() {
        self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
    }

    // MARK: - Views
    
    // logo
    internal lazy var logo: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView: UIImageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // text fields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .clear
        textField.autocorrectionType = .no
        //our users will have to use email to log in so this is a small little ux change
        textField.keyboardType = .emailAddress
       // textField.underLine(placeHolder: "Username")
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .clear
        //textField.underLine(placeHolder: "Password")
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()

    // buttons
    internal let loginButton: JashButton = {
        let button = JashButton(title: "Login")
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
      let button = JashButton(title: "Register")
        return button
    }()
}
