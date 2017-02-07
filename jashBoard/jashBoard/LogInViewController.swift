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
    
    let testLogin: JashTextField = JashTextField(placeHolder: "Jermaine")
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
        self.view.addSubview(usernameLabel)
        self.view.addSubview(passwordLabel)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(usernameLine)
        self.view.addSubview(passwordLine)
        self.view.addSubview(loginButton)
        self.view.addSubview(registerButton)
        self.view.addSubview(testLogin)
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
        usernameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(logo.snp.bottom).offset(16.0)
            view.leading.equalToSuperview().inset(16.0)
        }
        
        usernameTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(usernameLabel.snp.bottom).offset(16)
            textField.leading.equalToSuperview().offset(16)
            textField.trailing.equalToSuperview().inset(16)
        }
        
        testLogin.snp.makeConstraints { (view) in
            view.trailing.leading.equalToSuperview()
            view.bottom.equalTo(loginButton.snp.top)
        }
//        usernameTextField.snp.makeConstraints { (view) in
//            view.top.equalTo(usernameLabel.snp.top)
//            view.leading.equalTo(usernameLabel.snp.trailing).offset(8.0)
//            view.trailing.equalToSuperview().inset(16.0)
//            view.bottom.equalTo(usernameLabel.snp.bottom)
//        }
        
        usernameLine.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.bottom).offset(3.0)
            view.leading.equalTo(usernameLabel.snp.leading)
            view.trailing.equalTo(usernameTextField.snp.trailing)
            view.height.equalTo(1.0)
        }
        
        // password
        passwordLabel.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.bottom).offset(35.0)
            view.leading.equalToSuperview().inset(16.0)
        }
        
        passwordTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(passwordLabel.snp.bottom).offset(16)
            textField.leading.equalToSuperview().offset(16)
            textField.trailing.equalToSuperview().inset(16)
        }
        
//        passwordTextField.snp.makeConstraints { (view) in
//            view.top.equalTo(passwordLabel.snp.top)
//            view.leading.equalTo(passwordLabel.snp.trailing).offset(8.0)
//            view.trailing.equalToSuperview().inset(16.0)
//            view.bottom.equalTo(passwordLabel.snp.bottom)
//        }
        
        passwordLine.snp.makeConstraints { (view) in
            view.top.equalTo(passwordLabel.snp.bottom).offset(3.0)
            view.leading.equalTo(passwordLabel.snp.leading)
            view.trailing.equalTo(passwordTextField.snp.trailing)
            view.height.equalTo(1.0)
        }
        
        // register button
        registerButton.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(16.0)
            view.centerX.equalTo(self.view.snp.centerX)
            view.height.equalTo(30.0)
        }
        
        // login button
        loginButton.snp.makeConstraints { (view) in
            view.bottom.equalTo(registerButton.snp.top).inset(8.0)
            view.centerX.equalTo(self.view.snp.centerX)
            view.height.equalTo(30.0)
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

    // labels
    internal lazy var usernameLabel: UILabel = {
        let label = UILabel()
    //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = .red
        //        view.backgroundColor = JashColors.textAndIconColor
        label.text = "USERNAME"
        return label
    }()
    
    internal lazy var passwordLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = .red
        //        view.backgroundColor = JashColors.textAndIconColor
        label.text = "PASSWORD"
        return label
    }()
    
    // text fields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .clear
        textField.borderStyle = .bezel
        textField.backgroundColor = UIColor.green
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor.green
        return textField
    }()
    
    // lines
    internal lazy var usernameLine: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = JashColors.textAndIconColor
        return view
    }()
    
    internal lazy var passwordLine: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = JashColors.textAndIconColor
        return view
    }()
    
    // buttons
    internal lazy var loginButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("LOGIN", for: .normal)
        button.backgroundColor = JashColors.primaryColor
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(JashColors.textAndIconColor, for: .normal)
        button.layer.borderColor = JashColors.textAndIconColor.cgColor
        button.layer.borderWidth = 1.0
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("REGISTER", for: .normal)
        button.backgroundColor = JashColors.primaryColor
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(JashColors.textAndIconColor, for: .normal)
        button.layer.borderColor = JashColors.textAndIconColor.cgColor
        button.layer.borderWidth = 1.0
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
}
