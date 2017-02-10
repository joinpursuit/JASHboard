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
    //MARK: - Properties
    let testButton: UIButton = UIButton(type: UIButtonType.roundedRect)
    private var shouldAnimateLogo: Bool = true

  //MARK: - Functions
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOGIN/REGISTER"
        self.tabBarItem.title = ""
        self.view.backgroundColor = JashColors.primaryColor
        
        setupViewHierarchy()
        configureConstraints()
        
        // Textfield Delegate
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //FirAuth
        
        //MARK: - TO DO: after logging in and clicking the tab again, we return to the LOGIN/REGISTER screen with these buttons disabled but maybe we should hide them and or add a logout button since there is no way to log out otherwise. Re-factor this function.
        
        // Commenting this out because it's not necessary
//        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
//            if user?.email == nil {
//                self.loginButton.isEnabled = true
//                self.loginButton.isUserInteractionEnabled = true
//                self.registerButton.isEnabled = true
//                self.registerButton.isUserInteractionEnabled = true
//            } else {
//                self.loginButton.isEnabled = false
//                self.loginButton.isUserInteractionEnabled = false
//                self.registerButton.isEnabled = false
//                self.registerButton.isUserInteractionEnabled = false
//            }
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.animateLogo()
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
            // view.top.equalToSuperview().offset(16.0)
            view.centerY.equalToSuperview().offset(-8)
            view.centerX.equalToSuperview()
            view.size.equalTo(CGSize(width: 200, height: 200))
        }
        
        // username
        usernameTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(view.snp.bottom).offset(20)
            textField.centerX.equalToSuperview()
        }
        usernameTextField.underLine(placeHolder: "username")
        
        // password
        passwordTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(usernameTextField.snp.bottom).offset(30)
            textField.centerX.equalToSuperview()
        }
        
        testButton.setTitle("PROGRESS Test", for: .normal)
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
            view.bottom.equalTo(registerButton.snp.top).offset(-16.0)
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
        textField.shake()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Actions
    
    internal func didTapLogin(sender: UIButton) {
        print("-------LOGIN TAPPED-----")
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
            //self.signInUser = validUser
            self.navigationController?.pushViewController(UserHomeViewController(), animated: true)
            
            //clear password text field but keep username
            self.passwordTextField.text = nil
            self.passwordTextField.underLine(placeHolder: "Password")
        })
    }
    
    internal func didTapRegister(sender: UIButton) {
        print("-----did tap register------")
        let registerNewUserViewController = RegisterNewUserViewController()
        registerNewUserViewController.userEmailTextField.text = self.usernameTextField.text
        registerNewUserViewController.passwordTextField.text = self.passwordTextField.text
        self.navigationController?.pushViewController(registerNewUserViewController, animated: true)
        
        //clear password text field but keep username
        self.usernameTextField.text = nil
        self.usernameTextField.underLine(placeHolder: "Username")
        self.passwordTextField.text = nil
        self.passwordTextField.underLine(placeHolder: "Password")
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
    
    //MARK:- Animations
    
    private func animateLogo(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 2, dampingRatio: 0.8)
        
        if shouldAnimateLogo {
            
            animator.addAnimations({
                self.logo.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, delayFactor: 1)
            
            animator.addAnimations({
                self.logo.snp.remakeConstraints { (view) in
                    view.top.equalToSuperview().offset(16.0)
                    view.centerX.equalToSuperview()
                    view.size.equalTo(CGSize(width: 150, height: 150))
                }
                self.view.layoutIfNeeded()
            }, delayFactor: 0.5)
            
            animator.addAnimations({
                self.usernameTextField.snp.remakeConstraints{ (textField) in
                    textField.top.equalTo(self.logo.snp.bottom).offset(30)
                    textField.centerX.equalToSuperview()
                }
                self.usernameTextField.underLine(placeHolder: "username")
                self.view.layoutIfNeeded()
            }, delayFactor: 0.7)
            
            
            animator.addCompletion { (position) in
                
                if position == .end{
                    self.animateButtons()
                }
            }
            
            animator.startAnimation()
            
            //shouldAnimateLogo = !shouldAnimateLogo
            
        }else{
            
            logoUpAnimate()
        }
    }
    
    //Fix animation won't restart after coming to new tab
    private func logoUpAnimate(){
        let logoUp: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
        
        logoUp.addAnimations{
            self.logo.transform = CGAffineTransform(translationX: 0, y: 5)

        }
        
        logoUp.addCompletion { (position) in
            if position == .end{
                self.logoDown()
            }
        }
        
        logoUp.startAnimation()
        
    }
    
    private func logoDown(){
        let logoDown: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
        
        logoDown.addAnimations {
            self.logo.transform = CGAffineTransform(translationX: 0, y: -5)
        }
        
        logoDown.addCompletion { (position) in
            if position == .end{
                self.logoUpAnimate()
            }
        }
        
        logoDown.startAnimation()
    }
    
    private func animateButtons(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 2, dampingRatio: 0.5)
        
        let shadowAnim = CABasicAnimation()
        shadowAnim.keyPath = "shadowOpacity"
        shadowAnim.fromValue = NSNumber(value: 0.8)
        shadowAnim.toValue = NSNumber(value: 0.0)
        // shadowAnim.duration =
        self.loginButton.layer.add(shadowAnim, forKey: "shadowOpacity")
        self.registerButton.layer.add(shadowAnim, forKey: "shadowOpacity")
        
        
        animator.addAnimations {
            self.loginButton.alpha = 1
            self.registerButton.alpha = 1
            self.loginButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.registerButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            self.loginButton.layer.shadowColor = UIColor.black.cgColor
            self.loginButton.layer.shadowOffset = CGSize(width: 5, height: 5)
            self.loginButton.layer.shadowRadius = 5
            self.loginButton.layer.shadowOpacity = 0.8
            
        }
        
        animator.addAnimations({
            self.loginButton.layer.shadowOpacity = 0
            self.loginButton.transform = CGAffineTransform.identity
            
        }, delayFactor: 0.3)
        
        animator.addAnimations({
            self.registerButton.transform = CGAffineTransform.identity
            self.logo.transform = CGAffineTransform.identity
            
        }, delayFactor: 0.5)
        
        animator.addCompletion { (position) in
            if position == .end{
                self.logoUpAnimate()
            }
        }
        
        animator.startAnimation()
    }
    // MARK: - Views
    
    // logo
    internal lazy var logo: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView: UIImageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        return imageView
    }()
    
    // text fields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = JashColors.accentColor
        textField.autocorrectionType = .no
        //our users will have to use email to log in so this is a small little ux change
        textField.keyboardType = .emailAddress
        // textField.underLine(placeHolder: "Username")
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = JashColors.accentColor
        //textField.underLine(placeHolder: "Password")
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // buttons
    internal let loginButton: JashButton = {
        let button = JashButton(title: "Login")
        button.alpha = 0
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
        let button = JashButton(title: "Register")
        button.alpha = 0
        return button
    }()
}
