//
//  PreviewPopViewController.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/8/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit

class PreviewPopViewController: UIViewController {
    var image: UIImage?
    private let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7)
    private let tapGuesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .clear
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animator.startAnimation()
    }
    
    
    private func setUpView(){
        
        self.view.addSubview(blurView)
        self.view.addSubview(containerView)
        self.containerView.addSubview(imageView)
        
        imageView.image = image
        tapGuesture.addTarget(self, action: #selector(dismisspopup))
        self.blurView.addGestureRecognizer(tapGuesture)
        
        blurView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.9)
            view.height.equalToSuperview().multipliedBy(0.5)
        }
        
        imageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(10)
            view.bottom.equalToSuperview()
            view.leading.trailing.equalToSuperview()
        }
        
        animator.addAnimations {
           self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
           // self.containerView.alpha = 1
            self.view.layoutIfNeeded()
        }
        
    }
    
    func dismisspopup(){
        dismiss(animated: true, completion: nil)
    }
    
    private let blurView : UIView = {
        let view: UIView = UIView()
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
        
    }()
    
    private let imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let containerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = JashColors.textAndIconColor
        view.layer.cornerRadius = 10
        view.transform = CGAffineTransform(scaleX: 0, y: 0)
        //view.alpha = 0
        return view
        
    }()
    
}
