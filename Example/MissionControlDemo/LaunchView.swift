//
// LaunchView.swift
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

class LaunchView: BaseLaunchView {
    
    // MARK: - Properties

    var blinkTimer: Timer?
    var statusLightOffColor = UIColor(hex: "#4A4A4A")
    var statusLightOnColor = UIColor.white()
    var statusLightOn = false {
        didSet {
            if statusLightOn {
                UIView.animate(withDuration: 0.2) {
                    self.turnStatusLightOn()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.turnStatusLightOff()
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func commonInit() {
        super.commonInit()
        
        configureDefaultUI()
    }
    
    // MARK: - UI
    
    private func configureDefaultUI() {
        padding = 24.0
        
        gradientLayer.colors = [UIColor(hex: "#000000").cgColor, UIColor(hex: "#4A90E2").cgColor]
        gradientLayer.locations = [0.0, 1.0]
        
        buttonColor = UIColor.white()
        buttonHighlightColor = UIColor(hex: "#E4F6F6")
        statusTitleColor = UIColor.white()
        countdownColor = UIColor.white()
        
        buttonTitle.font = UIFont(name: "AvenirNext-Heavy", size: 36.0)
        statusTitle.font = UIFont(name: "Nasa-Display", size: 40.0)
        countdown.font = UIFont(name: "Nasa-Display", size: 256.0)
    }
    
    // MARK: - Blink
    
    func startBlinkingStatusLight(timeInterval: TimeInterval) {
        blinkTimer = Timer.scheduledTimer(timeInterval: timeInterval,
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
        
        statusLight.layer.shadowColor = statusLightOnColor.cgColor
        statusLight.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        statusLight.layer.shadowOpacity = 1.0
        statusLight.layer.shadowRadius = 5.0
    }
    
    func turnStatusLightOff() {
        statusLightColor = statusLightOffColor
        statusLight.layer.shadowOpacity = 0.0
    }
    
    // MARK: - Button Image Rotation
    
    func rotateButtonImageWithDuration(_ duration: Double) {
        buttonImage.rotate(withDuration: duration)
    }
    
    func stopRotatingButtonImage() {
        buttonImage.stopRotation()
    }
    
    // MARK: - Gradient Animation
    
    func animateGradientWithDuration(_ duration: Double) {
        animateGradientLayer(gradientLayer, withDuration: duration)
    }
    
    func stopAnimatingGradient() {
        stopGradientAnimation(gradientLayer)
    }

}

private extension UIView {
    
    @nonobjc static let rotationKey = "AERotation"
    
    func rotate(withDuration duration: Double = 1.0) {
        if layer.animation(forKey: UIView.rotationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(M_PI * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.rotationKey)
        }
    }
    
    func stopRotation() {
        layer.removeAnimation(forKey: UIView.rotationKey)
    }
    
    @nonobjc static let gradientKey = "AEGradientAnimation"
    
    func animateGradientLayer(_ gradientLayer: CAGradientLayer, withDuration duration: Double = 2.0) {
        if gradientLayer.animation(forKey: UIView.gradientKey) == nil {
            
            let sequenceDuration = duration / 4.0
            let currentLocations = [0.0, 1.0]
            let newLocations = [1.0, 1.0]
            
            let color1 = gradientLayer.colors![0]
            let color2 = gradientLayer.colors![1]
            
            // 1 / 4
            
            let locationAnimation1 = CABasicAnimation(keyPath: "locations")
            locationAnimation1.fromValue = currentLocations
            locationAnimation1.toValue = newLocations
            locationAnimation1.duration = sequenceDuration
            locationAnimation1.beginTime = 0.0
            
            // 2 / 4
            
            let colorAnimation1 = CABasicAnimation(keyPath: "colors")
            colorAnimation1.fromValue = [color1, color1]
            colorAnimation1.toValue = gradientLayer.colors?.reversed()
            colorAnimation1.duration = sequenceDuration
            colorAnimation1.isRemovedOnCompletion = false
            colorAnimation1.fillMode = kCAFillModeForwards
            colorAnimation1.beginTime = sequenceDuration
            
            // 3 / 4
            
            let locationAnimation2 = CABasicAnimation(keyPath: "locations")
            locationAnimation2.fromValue = currentLocations
            locationAnimation2.toValue = newLocations
            locationAnimation2.duration = sequenceDuration
            locationAnimation2.beginTime = 2 * sequenceDuration
            
            // 4 / 4
            
            let colorAnimation2 = CABasicAnimation(keyPath: "colors")
            colorAnimation2.fromValue = [color2, color2]
            colorAnimation2.toValue = gradientLayer.colors
            colorAnimation2.duration = sequenceDuration
            colorAnimation2.isRemovedOnCompletion = false
            colorAnimation2.fillMode = kCAFillModeForwards
            colorAnimation2.beginTime = 3 * sequenceDuration
            
            // Group
            
            let group = CAAnimationGroup()
            group.duration = duration
            group.animations = [locationAnimation1, colorAnimation1, locationAnimation2, colorAnimation2]
            group.repeatCount = Float.infinity

            gradientLayer.add(group, forKey: UIView.gradientKey)
        }
    }
    
    func stopGradientAnimation(_ gradientLayer: CAGradientLayer) {
        gradientLayer.removeAnimation(forKey: UIView.gradientKey)
    }
    
}
