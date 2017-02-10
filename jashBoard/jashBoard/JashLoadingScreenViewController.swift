//
//  JashLoadingScreenViewController.swift
//  jashBoard
//
//  Created by Jermaine Kelly on 2/10/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
protocol JashLoadingScreenProtocol{
    func showLoadingView()
    func dismissLoadingView()
}

class JashLoadingScreenViewController: UIViewController {
    private var dynamicBehavior: UIDynamicAnimator?
    private var gravity: UIGravityBehavior?
    private var collosion: UICollisionBehavior?
    private var bounceBehavior: UIDynamicItemBehavior?
    private let tapGuesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(viewTint)
        view.addSubview(barrier)
        
        tapGuesture.addTarget(self, action: #selector(dismissView))
        
        barrier.snp.makeConstraints { (view) in
            view.centerY.leading.trailing.equalToSuperview()
            view.height.equalTo(10)
        }
        viewTint.addGestureRecognizer(tapGuesture)
        viewTint.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
       self.edgesForExtendedLayout = []
        
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createBalls), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dynamicBehavior  = UIDynamicAnimator(referenceView: view)
        let snapBehavior: UISnapBehavior = UISnapBehavior(item: barrier, snapTo: view.center)
        gravity = UIGravityBehavior()
        gravity?.magnitude = 0.7
        gravity?.angle = CGFloat.pi / 2.3
        collosion  = UICollisionBehavior()
        collosion?.translatesReferenceBoundsIntoBoundary = true
        collosion?.addItem(barrier)
        bounceBehavior = UIDynamicItemBehavior()
        bounceBehavior?.elasticity = 0.7
        dynamicBehavior?.addBehavior(gravity!)
        dynamicBehavior?.addBehavior(collosion!)
        dynamicBehavior?.addBehavior(snapBehavior)
        dynamicBehavior?.addBehavior(bounceBehavior!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    func createBalls(){
        let ball: UIView = UIView()
        
        view.addSubview(ball)

        ball.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview().inset(-50)
            view.centerY.equalToSuperview().inset(-50)
            view.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        ball.layer.cornerRadius = 6
        ball.backgroundColor = randomColor
        
        view.layoutIfNeeded()
        
        gravity?.addItem(ball)
        collosion?.addItem(ball)
        bounceBehavior?.addItem(ball)
    }
    
    func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    private var randomColor: UIColor?{
        let colorsArray = [JashColors.accentColor,JashColors.textAndIconColor,JashColors.lightPrimaryColor]
        let randIndex = Int(arc4random_uniform(3))
        return colorsArray[randIndex]
    }
    
    private let viewTint: UIView  = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.2
        return view
    }()
    
    private let barrier: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.isHidden = true
        return view
    }()
    
}

