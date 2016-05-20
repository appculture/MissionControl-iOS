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

    override func commonInit() {
        super.commonInit()
        
        configureUI()
        updateUIForState(.Offline)
    }
    
    private func configureUI() {
        padding = 24.0
        
        gradientLayer.colors = [UIColor(hex: "000000").CGColor, UIColor(hex: "4A90E2").CGColor]
        
        button.backgroundColor = UIColor.whiteColor()
        buttonTitle.font = UIFont(name: "AvenirNext-Heavy", size: 36.0)
        
        statusLabel.font = UIFont(name: "Nasa-Display", size: 40.0)
        statusLabel.textColor = UIColor.whiteColor()
        
        countdown.font = UIFont(name: "Nasa-Display", size: 256.0)
    }
    
    private func updateUIForState(state: LaunchState) {
        button.layer.borderColor = colorForState(state).CGColor
        buttonTitle.textColor = colorForState(state)
        buttonTitle.text = commandForState(state)
        
        statusLight.backgroundColor = colorForState(state)
        statusLabel.text = "STATUS: \(state.rawValue.capitalizedString)"

        countdown.alpha = state == .Offline ? 0.1 : 1.0
        countdown.text = "00"
    }
    
    private func colorForState(state: LaunchState) -> UIColor {
        switch state {
        case .Offline:
            return UIColor(hex: "#4A4A4A")
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

}
