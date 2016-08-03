//
// LaunchBrain.swift
// MissionControlDemo
//
// Copyright (c) 2016 appculture <dev@appculture.com> http://appculture.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    var timer: Timer?
    
    private var launchForce: Double {
        return 1.0 - ConfigDouble("LaunchForce", fallback: 0.5)
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
    
    func missionControlDidRefreshConfig(old: [String : AnyObject]?, new: [String : AnyObject]) {
        print("missionControlDidRefreshConfig")
        updateUIForState(state)
    }
    
    func missionControlDidFailRefreshingConfig(error: Error) {
        print("missionControlDidFailRefreshingConfig")
        
        stopCountdown()

        switch state {
        case .Countdown:
            state = .Failed
        default:
            state = .Offline
        }
    }
    
    // MARK: - Actions
    
    func didTapButton(_ sender: AnyObject) {
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
    
    private func updateUIForState(_ state: LaunchState) {
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
    
    private func updateUIForAnyState(_ state: LaunchState) {
        let color1 = UIColor(hex: ConfigString("TopColor", fallback: "#000000"))
        let color2 = UIColor(hex: ConfigString("BottomColor", fallback: "#4A90E2"))
        view.gradientLayer.colors = [color1.cgColor, color2.cgColor]
        
        view.button.layer.borderColor = colorForState(state).cgColor
        view.buttonTitle.text = commandForState(state)
        
        view.stopBlinkingStatusLight()
        view.statusTitle.text = "STATUS: \(state.rawValue.capitalized)"
        view.statusLightOnColor = colorForState(state)
        view.statusLightOn = true
        
        view.countdown.alpha = 1.0
    }
    
    private func updateUIForOfflineState() {
        view.stopAnimatingGradient()
        view.stopRotatingButtonImage()
        
        view.button.layer.borderColor = view.statusLightOffColor.cgColor
        view.countdown.alpha = 0.1
        seconds = 0
        view.startBlinkingStatusLight(timeInterval: 0.5)
    }
    
    private func updateUIForReadyState() {
        seconds = ConfigInt("CountdownDuration", fallback: 10)
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
    
    private func commandForState(_ state: LaunchState) -> String {
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
    
    private func colorForState(_ state: LaunchState) -> UIColor {
        switch state {
        case .Offline:
            return UIColor(hex: ConfigString("OfflineColor", fallback: "#F8E71C"))
        case .Ready:
            return UIColor(hex: ConfigString("ReadyColor", fallback: "#7ED321"))
        case .Countdown:
            return UIColor(hex: ConfigString("CountdownColor", fallback: "#F5A623"))
        case .Launched:
            return UIColor(hex: ConfigString("LaunchedColor", fallback: "#BD10E0"))
        case .Failed:
            return UIColor(hex: ConfigString("FailedColor", fallback: "#D0021B"))
        case .Aborted:
            return UIColor(hex: ConfigString("AbortedColor", fallback: "#D0021B"))
        }
    }
    
    // MARK: - Countdown
    
    private func startCountdown() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                                           target: self,
                                                           selector: #selector(timerTick(_:)),
                                                           userInfo: nil, repeats: true)
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerTick(_ sender: Timer) {
        ConfigBoolForce("Abort", fallback: true) { (forced) in
            if forced {
                self.stopCountdown()
                self.state = .Aborted
            }
        }

        if seconds - 1 >= 0 {
            seconds -= 1
        } else {
            stopCountdown()
            state = .Launched
        }
    }
    
}
