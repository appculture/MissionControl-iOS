//
//  MCLaunchView.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

enum LaunchState: String {
    case Offline
    case Ready
    case Countdown
    case Launched
    case Failed
    case Aborted
}

class MCLaunchView: LaunchView {
    
    // MARK: - Properties
    
    var state: LaunchState = .Offline {
        didSet {
            updateUIForState(state)
        }
    }

    var blinkTimer: NSTimer?
    var statusLightOffColor = UIColor(hex: "#4A4A4A")
    var statusLightOn = false
    
    // MARK: - Lifecycle
    
    override func commonInit() {
        super.commonInit()
        
        configureUI()
        updateUIForState(.Offline)
        startBlinkingStatusLight()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        padding = 24.0
        
        buttonColor = UIColor.whiteColor()
        buttonHighlightColor = UIColor(hex: "#E4F6F6")
        statusTextColor = UIColor.whiteColor()
        countdownColor = UIColor.whiteColor()
        
        gradientLayer.colors = [UIColor(hex: "#000000").CGColor, UIColor(hex: "#4A90E2").CGColor]
        
        buttonTitle.font = UIFont(name: "AvenirNext-Heavy", size: 36.0)
        statusLabel.font = UIFont(name: "Nasa-Display", size: 40.0)
        countdown.font = UIFont(name: "Nasa-Display", size: 256.0)
    }
    
    private func updateUIForState(state: LaunchState) {
        statusColor = colorForState(state)
        
        if state == .Offline {
            statusLight.backgroundColor = statusLightOffColor
            button.layer.borderColor = statusLightOffColor.CGColor
        }
        
        buttonTitle.text = commandForState(state)
        statusLabel.text = "STATUS: \(state.rawValue.capitalizedString)"
        
        countdown.alpha = state == .Offline ? 0.1 : 1.0
        countdown.text = "00"
    }
    
    private func colorForState(state: LaunchState) -> UIColor {
        switch state {
        case .Offline:
            return UIColor(hex: "#F8E71C")
        case .Ready:
            return UIColor(hex: "#7ED321")
        case .Countdown:
            return UIColor(hex: "#F5A623")
        case .Launched:
            return UIColor(hex: "#BD10E0")
        case .Failed, .Aborted:
            return UIColor(hex: "#D0021B")
        }
    }
    
    private func commandForState(state: LaunchState) -> String {
        switch state {
        case .Offline:
            return "CONNECT"
        case .Ready:
            return "LAUNCH"
        case .Countdown:
            return "ABORT"
        case .Launched, .Failed, .Aborted:
            return "RETRY"
        }
    }
    
    // MARK: - Blink
    
    func startBlinkingStatusLight() {
        blinkTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                                                            target: self,
                                                            selector: #selector(blinkStatusLight),
                                                            userInfo: nil, repeats: true)
    }
    
    func stopBlinkingStatusLight() {
        blinkTimer?.invalidate()
        blinkTimer = nil
    }
    
    @objc func blinkStatusLight() {
        if statusLightOn {
            statusLightOn = false
            UIView.animateWithDuration(0.3) {
                self.turnStatusLightOff()
            }
        } else {
            statusLightOn = true
            UIView.animateWithDuration(0.3) {
                self.turnStatusLightOn()
            }
        }
    }
    
    func turnStatusLightOn() {
        let color = colorForState(state)
        statusLight.backgroundColor = color
        
        statusLight.layer.shadowColor = color.CGColor
        statusLight.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        statusLight.layer.shadowOpacity = 1.0
        statusLight.layer.shadowRadius = 5.0
    }
    
    func turnStatusLightOff() {
        statusLight.backgroundColor = statusLightOffColor
        statusLight.layer.shadowOpacity = 0.0
    }

}
