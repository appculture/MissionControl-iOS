//
//  LaunchView.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class LaunchView: BaseLaunchView {
    
    // MARK: - Properties

    var blinkTimer: NSTimer?
    var statusLightOffColor = UIColor(hex: "#4A4A4A")
    var statusLightOnColor = UIColor.whiteColor()
    var statusLightOn = false {
        didSet {
            if statusLightOn {
                UIView.animateWithDuration(0.3) {
                    self.turnStatusLightOn()
                }
            } else {
                UIView.animateWithDuration(0.3) {
                    self.turnStatusLightOff()
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func commonInit() {
        super.commonInit()
        
        configureUI()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        padding = 24.0
        
        gradientLayer.colors = [UIColor(hex: "#000000").CGColor, UIColor(hex: "#4A90E2").CGColor]
        
        buttonColor = UIColor.whiteColor()
        buttonHighlightColor = UIColor(hex: "#E4F6F6")
        statusTitleColor = UIColor.whiteColor()
        countdownColor = UIColor.whiteColor()
        
        buttonTitle.font = UIFont(name: "AvenirNext-Heavy", size: 36.0)
        statusTitle.font = UIFont(name: "Nasa-Display", size: 40.0)
        countdown.font = UIFont(name: "Nasa-Display", size: 256.0)
    }
    
    // MARK: - Blink
    
    func startBlinkingStatusLight(timeInterval timeInterval: NSTimeInterval) {
        blinkTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
                                                            target: self,
                                                            selector: #selector(blinkStatusLight),
                                                            userInfo: nil, repeats: true)
    }
    
    func stopBlinkingStatusLight() {
        blinkTimer?.invalidate()
        blinkTimer = nil
    }
    
    @objc func blinkStatusLight() {
        statusLightOn = !statusLightOn
    }
    
    func turnStatusLightOn() {
        statusLightColor = statusLightOnColor
        
        statusLight.layer.shadowColor = statusLightOnColor.CGColor
        statusLight.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        statusLight.layer.shadowOpacity = 1.0
        statusLight.layer.shadowRadius = 5.0
    }
    
    func turnStatusLightOff() {
        statusLightColor = statusLightOffColor
        statusLight.layer.shadowOpacity = 0.0
    }

}
