//
//  JashProgressViewController.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/8/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

protocol JashProgressBarDelegate{
    func upDateProgressbar(value: Float)
}

class JashProgressViewController: UIViewController,JashProgressBarDelegate {
    
    let dismissButton: UIButton = UIButton(type: UIButtonType.roundedRect)

    private var dismissAnimate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .clear
        self.dismissButton.addTarget(self, action: #selector(uploadSucess), for: .touchUpInside)
        setUpViews()
    }
    
    
    private func setUpViews(){
        self.view.addSubview(viewControllerTint)
        self.view.addSubview(container)
        self.container.addSubview(dismissButton)
        self.container.addSubview(titleLabel)
        self.container.addSubview(progressBar)
        self.container.addSubview(upArrow)
        
        viewControllerTint.snp.makeConstraints { (view) in
            view.top.bottom.trailing.leading.equalToSuperview()
        }
        
        dismissButton.isHidden = true
        container.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.width.equalTo(self.view.snp.width).multipliedBy(0.7)
            view.height.equalTo(self.view.snp.height).multipliedBy(0.1)
        }
        
        titleLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(10)
            view.centerX.equalToSuperview()
        }
        
        progressBar.snp.makeConstraints { (view) in
            view.top.equalTo(titleLabel.snp.bottom).offset(10)
            view.leading.equalToSuperview().offset(10)
            view.trailing.equalToSuperview().inset(10)
        }
        upArrow.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
        }
        dismissButton.snp.makeConstraints { (view) in
            view.bottom.centerX.equalToSuperview()
        }
        
        dismissButton.setTitle("Dismiss", for: .normal)
        
       // Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(upDateProgressbar), userInfo: nil, repeats: true)
    }
    
    //MARK: - Progress bar delegate method
    func upDateProgressbar(value: Float) {
        DispatchQueue.main.async {
            self.progressBar.progress = value
        }
        print(value)
        
        if value == 1.0 && dismissAnimate{
            self.uploadSucess()
            dismissAnimate = !dismissAnimate
        }
    }
    
    //MARK: - Animations
    func uploadSucess(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
        
        self.titleLabel.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
        }
        
        animator.addAnimations {
            self.titleLabel.text = "SUCCESS!"
            self.progressBar.alpha = 0
            self.titleLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.view.layoutIfNeeded()
        }
        
        animator.addCompletion { (position) in
            if position == .end{
                self.animateContainer()
            }
        }
        
        animator.startAnimation()
    }
    
    private func animateContainer(){
        
        let containerAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.7, curve: .easeIn)
        //Allows animating the corner radius
        let cornerRadius = CABasicAnimation()
        cornerRadius.keyPath = "cornerRadius"
        cornerRadius.fromValue = NSNumber(value: 10)
        cornerRadius.toValue = NSNumber(value: 35)
        container.layer.add(cornerRadius, forKey: "cornerRadius")
        
        container.snp.remakeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.size.equalTo(CGSize(width: 70, height: 70))
        }
        
        containerAnimator.addAnimations ({
            self.titleLabel.alpha = 0
            self.dismissButton.alpha = 0
            self.container.layer.cornerRadius = 35
            self.view.layoutIfNeeded()
        }, delayFactor: 0.2)
        
        containerAnimator.addCompletion { (position) in
            if position == .end{
                self.animateArrow()
            }
        }
        
        containerAnimator.startAnimation()
    }
    
    private func animateArrow(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 2, dampingRatio: 0.3)
        
        animator.addAnimations{
            self.upArrow.alpha = 0.7
            self.upArrow.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        animator.addCompletion { (position) in
            if position == .end{
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        animator.startAnimation()
    }
    
    private let viewControllerTint: UIView = {
        let view: UIView = UIView()
        view.alpha  = 0.5
        view.backgroundColor = .black
        return view
    }()
    
    private let container: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = JashColors.primaryColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "UPLOADING..."
        label.textColor = JashColors.accentColor
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let bar: UIProgressView = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = JashColors.textAndIconColor
        bar.progressTintColor = JashColors.accentColor
        return bar
    }()
    
    private let upArrow: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "up_arrow")
        imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = .white
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        return imageView
    }()
}
