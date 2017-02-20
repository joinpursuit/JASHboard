//
//  Pulsing.swift
//  jashBoard
//
//  Created by Ana Ma on 2/9/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import Foundation
import UIKit

//https://www.youtube.com/watch?v=DNr5D7DSMr8
class Pulsing: CALayer {
    var animationGroup = CAAnimationGroup()
    var initialPalseScale: Float = 0
    var nextPalseAfter: TimeInterval = 0
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numberOfPalses: Float = Float.infinity
    
    override init (layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (numberOfPalses: Float = Float.infinity, radius: CGFloat, position: CGPoint) {
        super.init()
        self.backgroundColor = JashColors.accentColor.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numberOfPalses = numberOfPalses
        self.position = position
        
        self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        self.cornerRadius = radius
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }
    
    func creationScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation.init(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: initialPalseScale)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath:"opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [0.4, 0.8, 0]
        opacityAnimation.keyTimes =  [0, 0.2, 1]
        return opacityAnimation
    }
    
    func setupAnimationGroup() {
        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = animationDuration + nextPalseAfter
        self.animationGroup.repeatCount = numberOfPalses
        
        let easeInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.animationGroup.timingFunction = easeInEaseOut
        
        self.animationGroup.animations = [createOpacityAnimation(),creationScaleAnimation()]
    }
    
}
