//
//  LogInViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    let testLogin: UITextField = UITextField()
    var signInUser: FIRUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOGIN/REGISTER"
        self.view.backgroundColor = JashColors.primaryColor
        setupViewHierarchy()
        configureConstraints()
    }
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(logo)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(registerButton)
        loginButton.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister(sender:)), for: .touchUpInside)
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
    
    internal func didTapLogin(sender: UIButton) {
        guard let userName = usernameTextField.text,
            let password = passwordTextField.text else { return }
        FIRAuth.auth()?.signIn(withEmail: userName, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Error present when login button is pressed")
                let errorAlertController = UIAlertController(title: "User Not Present", message: "Please register first", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
            }
            guard let validUser = user else { return }
            self.signInUser = validUser
            let logginAlertController = UIAlertController(title: "Logged In Successfully", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            logginAlertController.addAction(okay)
            self.present(logginAlertController, animated: true, completion: nil)
            self.loginButton.setTitle("LOGOUT", for: UIControlState.normal)
            self.loginButton.addTarget(self, action: #selector(self.didTapLogout(sender:)), for: UIControlEvents.touchUpInside)
        })
    }
    
    internal func didTapRegister(sender: UIButton) {
        guard let userName = usernameTextField.text,
            let password = passwordTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: userName, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Error present when register button is pressed")
            }
            guard let validUser = user else { return }
            self.signInUser = validUser
            print("User is registered")
        })
    }
    
    private func loginAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Error attempting to long in anonymously: \(error!)")
            }
            if user != nil {
                print("Signed in anonymously!")
                self.signInUser = user
            }
        })
    }
    
    func didTapLogout(sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let alertController = UIAlertController(title: "Logged Out Successfully", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(okay)
            present(alertController, animated: true, completion: nil)
            
            self.loginButton.setTitle("LOGIN", for: UIControlState.normal)
            self.loginButton.addTarget(self, action: #selector(didTapLogin(sender:)), for: UIControlEvents.touchUpInside)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Views
    
    // containerView 
    
    internal lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
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
       // textField.underLine(placeHolder: "Username")
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .clear
        //textField.underLine(placeHolder: "Password")
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
