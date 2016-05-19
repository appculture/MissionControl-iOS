//
//  LaunchView.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

@IBDesignable
class LaunchView: UIView {
    
    // MARK: - Outlets
    
    let gradient = UIView()

    let button = UIButton()
    let statusLabel = UILabel()
    let statusLight = UIView()
    let countdown = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRectZero)
        commonInit()
    }
    
    private func commonInit() {
        configureOutlets()
        configureHierarchy()
        updateConstraints()
    }
    
    // MARK: - Configure Outlets
    
    private func configureOutlets() {
        configureGradient()
        configureButton()
        configureStatus()
        configureCountdown()
    }
    
    private func configureGradient() {
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.backgroundColor = UIColor.blueColor()
    }
    
    private func configureButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.darkGrayColor().CGColor
        button.layer.borderWidth = 10.0
        button.layer.cornerRadius = 10.0
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitle("CONNECT", forState: .Normal)
    }
    
    private func configureStatus() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.setContentHuggingPriority(251.0, forAxis: .Vertical)
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.textAlignment = .Center
        statusLabel.text = "STATUS: OFFLINE"
        
        statusLight.translatesAutoresizingMaskIntoConstraints = false
        statusLight.backgroundColor = UIColor.darkGrayColor()
        statusLight.layer.cornerRadius = 16.0
    }
    
    private func configureCountdown() {
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.textColor = UIColor.whiteColor()
        countdown.textAlignment = .Center
        countdown.text = "00"
    }
    
    // MARK: - Configure Layout
    
    private func configureHierarchy() {
        gradient.addSubview(button)
        gradient.addSubview(statusLabel)
        gradient.addSubview(statusLight)
        gradient.addSubview(countdown)
        
        addSubview(gradient)
    }
    
    override func updateConstraints() {
        NSLayoutConstraint.deactivateConstraints(allConstraints)
        NSLayoutConstraint.activateConstraints(allConstraints)
        super.updateConstraints()
    }
    
    // MARK: - Constraints
    
    private var allConstraints: [NSLayoutConstraint] {
        var constraints = gradientConstraints + buttonConstraints
        constraints += statusLabelConstraints + statusLightConstraints
        constraints += countdownConstraints
        return constraints
    }
    
    private var gradientConstraints: [NSLayoutConstraint] {
        let leading = gradient.leadingAnchor.constraintEqualToAnchor(leadingAnchor)
        let trailing = gradient.trailingAnchor.constraintEqualToAnchor(trailingAnchor)
        let top = gradient.topAnchor.constraintEqualToAnchor(topAnchor)
        let bottom = gradient.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
        return [leading, trailing, top, bottom]
    }
    
    private var buttonConstraints: [NSLayoutConstraint] {
        let leading = button.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 24.0)
        let trailing = button.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -24.0)
        let bottom = button.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -24.0)
        let height = button.heightAnchor.constraintEqualToConstant(90.0)
        return [leading, trailing, bottom, height]
    }
    
    private var statusLabelConstraints: [NSLayoutConstraint] {
        let leading = statusLabel.leadingAnchor.constraintEqualToAnchor(button.leadingAnchor)
        let trailing = statusLabel.trailingAnchor.constraintEqualToAnchor(button.trailingAnchor)
        let bottom = statusLabel.bottomAnchor.constraintEqualToAnchor(button.topAnchor, constant: -24.0)
        return [leading, trailing, bottom]
    }
    
    private var statusLightConstraints: [NSLayoutConstraint] {
        let centerX = statusLight.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        let bottom = statusLight.bottomAnchor.constraintEqualToAnchor(statusLabel.topAnchor, constant: -24.0)
        let width = statusLight.widthAnchor.constraintEqualToConstant(32.0)
        let height = statusLight.heightAnchor.constraintEqualToConstant(32.0)
        return [centerX, bottom, width, height]
    }
    
    private var countdownConstraints: [NSLayoutConstraint] {
        let leading = countdown.leadingAnchor.constraintEqualToAnchor(button.leadingAnchor)
        let trailing = countdown.trailingAnchor.constraintEqualToAnchor(button.trailingAnchor)
        let top = countdown.topAnchor.constraintEqualToAnchor(topAnchor)
        let bottom = countdown.bottomAnchor.constraintEqualToAnchor(statusLight.topAnchor)
        return [leading, trailing, top, bottom]
    }
    
}
