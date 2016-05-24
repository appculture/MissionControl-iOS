//
//  LaunchBrain.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/20/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit
import MissionControl

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

class LaunchBrain: MissionControlDelegate {
    
    // MARK: - Properties
    
    var view: LaunchView!
    weak var delegate: LaunchDelegate?
    
    var state: LaunchState = .Offline {
        didSet {
            updateUIForState(state)
        }
    }
    
    var seconds: Int = 0 {
        didSet {
            view.countdown.text = String(format: "%02d", seconds)
        }
    }
    
    var timer: NSTimer?
    
    private var launchForce: Double {
        return 1.0 - ConfigDouble("LaunchForce", 0.5)
    }
    
    // MARK: - Init
    
    init(view: LaunchView, delegate: LaunchDelegate) {
        self.view = view
        self.delegate = delegate
        
        MissionControl.delegate = self
        
        self.view.didTapButtonAction = { sender in
            self.didTapButton(sender)
        }
        
        updateUI()
    }
    
    // MARK: - MissionControlDelegate
    
    func missionControlDidRefreshConfig(old old: [String : AnyObject]?, new: [String : AnyObject]) {
        print("missionControlDidRefreshConfig")
        updateUIForState(state)
    }
    
    func missionControlDidFailRefreshingConfig(error error: ErrorType) {
        print("missionControlDidFailRefreshingConfig")
    }
    
    // MARK: - Actions
    
    func didTapButton(sender: AnyObject) {
        switch state {
        case .Offline:
            ConfigBoolForce("Ready", fallback: false, completion: { (forced) in
                if forced {
                    self.state = .Ready
                } else {
                    self.state = .Failed
                }
            })
        case .Ready:
            state = .Countdown
        case .Countdown:
            state = .Aborted
        case .Failed, .Aborted, .Launched:
            state = .Offline
        }
    }
    
    // MARK: - UI
    
    func updateUI() {
        updateUIForState(state)
    }
    
    private func updateUIForState(state: LaunchState) {
        updateUIForAnyState(state)
        
        switch state {
        case .Offline:
            updateUIForOfflineState()
        case .Ready:
            updateUIForReadyState()
        case .Countdown:
            updateUIForCountdownState()
            startCountdown()
        case .Launched:
            updateUIForLaunchedState()
        case .Failed:
            updateUIForFailedState()
        case .Aborted:
            stopCountdown()
            updateUIForAbortedState()
        }
    }
    
    private func updateUIForAnyState(state: LaunchState) {
        let color1 = UIColor(hex: ConfigString("TopColor", "#000000"))
        let color2 = UIColor(hex: ConfigString("BottomColor", "#4A90E2"))
        view.gradientLayer.colors = [color1.CGColor, color2.CGColor]
        
        view.button.layer.borderColor = colorForState(state).CGColor
        view.buttonTitle.text = commandForState(state)
        
        view.stopBlinkingStatusLight()
        view.statusTitle.text = "STATUS: \(state.rawValue.capitalizedString)"
        view.statusLightOnColor = colorForState(state)
        view.statusLightOn = true
        
        view.countdown.alpha = 1.0
    }
    
    private func updateUIForOfflineState() {
        view.stopAnimatingGradient()
        view.stopRotatingButtonImage()
        
        view.button.layer.borderColor = view.statusLightOffColor.CGColor
        view.countdown.alpha = 0.1
        seconds = 0
        view.startBlinkingStatusLight(timeInterval: 0.5)
    }
    
    private func updateUIForReadyState() {
        seconds = ConfigInt("CountdownDuration", 10)
    }
    
    private func updateUIForCountdownState() {
        let duration = launchForce * 4
        view.rotateButtonImageWithDuration(duration)
        view.startBlinkingStatusLight(timeInterval: 0.25)
    }
    
    private func updateUIForLaunchedState() {
        view.countdown.text = "OK"

        view.animateGradientWithDuration(launchForce * 8)
        
        view.stopRotatingButtonImage()
        let duration = launchForce * 2
        view.rotateButtonImageWithDuration(duration)
    }
    
    private func updateUIForFailedState() {
        view.countdown.text = "F"
        view.startBlinkingStatusLight(timeInterval: 0.5)
    }
    
    private func updateUIForAbortedState() {
        view.stopRotatingButtonImage()
        view.countdown.text = "A"
        view.startBlinkingStatusLight(timeInterval: 0.25)
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
            return UIColor(hex: ConfigString("OfflineColor", "#F8E71C"))
        case .Ready:
            return UIColor(hex: ConfigString("ReadyColor", "#7ED321"))
        case .Countdown:
            return UIColor(hex: ConfigString("CountdownColor", "#F5A623"))
        case .Launched:
            return UIColor(hex: ConfigString("LaunchedColor", "#BD10E0"))
        case .Failed:
            return UIColor(hex: ConfigString("FailedColor", "#D0021B"))
        case .Aborted:
            return UIColor(hex: ConfigString("AbortedColor", "#D0021B"))
        }
    }
    
    // MARK: - Countdown
    
    private func startCountdown() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                                                           target: self,
                                                           selector: #selector(timerTick(_:)),
                                                           userInfo: nil, repeats: true)
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerTick(sender: NSTimer) {
        /// - TODO: implement force sync parameter
        if ConfigBool("Abort") {
            stopCountdown()
            state = .Aborted
        } else {
            if seconds - 1 >= 0 {
                seconds -= 1
            } else {
                stopCountdown()
                state = .Launched
            }
        }
    }
    
}
