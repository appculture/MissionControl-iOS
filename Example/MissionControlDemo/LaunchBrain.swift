//
//  LaunchBrain.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/20/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

protocol LaunchDelegate: class {
    
}

enum LaunchState: String {
    case Offline
    case Ready
    case Countdown
    case Launched
    case Failed
    case Aborted
}

class LaunchBrain {
    
    // MARK: - Properties
    
    var view: LaunchView!
    weak var delegate: LaunchDelegate?
    
    var state: LaunchState = .Offline {
        didSet {
            updateUIForState(state)
        }
    }
    
    // MARK: - Init
    
    init(view: LaunchView, delegate: LaunchDelegate) {
        self.view = view
        self.delegate = delegate
        
        self.view.didTapButtonAction = { sender in
            self.didTapButton(sender)
        }
        
        updateUIForState(.Offline)
    }
    
    func didTapButton(sender: AnyObject) {
        updateUIForState(.Ready)
    }
    
    func updateUIForState(state: LaunchState) {
        view.button.layer.borderColor = colorForState(state).CGColor
        view.buttonTitle.text = commandForState(state)
        
        view.statusTitle.text = "STATUS: \(state.rawValue.capitalizedString)"
        view.statusLightOnColor = colorForState(state)
        view.statusLightOn = true
        
        view.countdown.alpha = 1.0
        
        switch state {
        case .Offline:
            view.button.layer.borderColor = view.statusLightOffColor.CGColor
            view.countdown.alpha = 0.1
            view.countdown.text = "00"
            view.startBlinkingStatusLight(timeInterval: 0.5)
        case .Ready:
            view.countdown.text = "10"
            view.stopBlinkingStatusLight()
        default:
            break
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
    
}
