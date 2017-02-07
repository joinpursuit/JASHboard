//
//  LogInViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOGIN/REGISTER"
        self.view.backgroundColor = JashColors.primaryColor
        setupViewHierarchy()
        configureConstraints()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        usernameTextField.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.top)
            view.leading.equalTo(usernameLabel.snp.trailing).offset(8.0)
            view.trailing.equalToSuperview().inset(16.0)
            view.bottom.equalTo(usernameLabel.snp.bottom)
        }
        
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
        
        passwordTextField.snp.makeConstraints { (view) in
            view.top.equalTo(passwordLabel.snp.top)
            view.leading.equalTo(passwordLabel.snp.trailing).offset(8.0)
            view.trailing.equalToSuperview().inset(16.0)
            view.bottom.equalTo(passwordLabel.snp.bottom)
        }
        
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
    }
    
    internal func didTapRegister(sender: UIButton) {
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
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.borderStyle = .bezel
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
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
