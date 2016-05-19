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
    let gradientLayer = CAGradientLayer()

    let button = UIButton()
    let logoImage = UIImageView()
    let statusLabel = UILabel()
    let statusLight = UIView()
    let countdown = UILabel()
    
    // MARK: - Properties
    
    var padding: CGFloat = 24.0
    
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
    
    func commonInit() {
        configureOutlets()
        configureHierarchy()
        updateConstraints()
    }
    
    // MARK: - Override
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        gradientLayer.frame = gradient.bounds
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
        gradient.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        gradientLayer.colors = [UIColor.orangeColor().CGColor, UIColor.blueColor().CGColor]
        gradientLayer.contentsScale = UIScreen.mainScreen().scale
        gradientLayer.drawsAsynchronously = true
        gradientLayer.needsDisplayOnBoundsChange = true
        gradientLayer.setNeedsDisplay()
    }
    
    private func configureButton() {
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.image = UIImage(named: "appculture")
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.darkGrayColor().CGColor
        button.layer.borderWidth = 10.0
        button.layer.cornerRadius = 10.0
        button.clipsToBounds = true
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        button.setTitle("BUTTON", forState: .Normal)
    }
    
    private func configureStatus() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.setContentHuggingPriority(251.0, forAxis: .Vertical)
        statusLabel.textAlignment = .Center
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.text = "STATUS"
        
        statusLight.translatesAutoresizingMaskIntoConstraints = false
        statusLight.backgroundColor = UIColor.darkGrayColor()
        statusLight.layer.borderColor = UIColor.whiteColor().CGColor
        statusLight.layer.borderWidth = 2.0
        statusLight.layer.cornerRadius = 16.0
        statusLight.clipsToBounds = true
    }
    
    private func configureCountdown() {
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.textAlignment = .Center
        countdown.textColor = UIColor.whiteColor()
        countdown.text = "00"
    }
    
    // MARK: - Configure Layout
    
    private func configureHierarchy() {
        button.addSubview(logoImage)
        
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
        var constraints = gradientConstraints
        constraints += buttonConstraints + logoConstraints
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
        let leading = button.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: padding)
        let trailing = button.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -padding)
        let bottom = button.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -padding)
        let height = button.heightAnchor.constraintEqualToConstant(90.0)
        return [leading, trailing, bottom, height]
    }
    
    private var logoConstraints: [NSLayoutConstraint] {
        let leading = logoImage.leadingAnchor.constraintEqualToAnchor(button.leadingAnchor, constant: 20.0)
        let centerY = logoImage.centerYAnchor.constraintEqualToAnchor(button.centerYAnchor)
        let width = logoImage.widthAnchor.constraintEqualToConstant(46.0)
        let height = logoImage.heightAnchor.constraintEqualToConstant(49.0)
        return [leading, centerY, width, height]
    }
    
    private var statusLabelConstraints: [NSLayoutConstraint] {
        let leading = statusLabel.leadingAnchor.constraintEqualToAnchor(button.leadingAnchor)
        let trailing = statusLabel.trailingAnchor.constraintEqualToAnchor(button.trailingAnchor)
        let bottom = statusLabel.bottomAnchor.constraintEqualToAnchor(button.topAnchor, constant: -padding)
        return [leading, trailing, bottom]
    }
    
    private var statusLightConstraints: [NSLayoutConstraint] {
        let centerX = statusLight.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        let bottom = statusLight.bottomAnchor.constraintEqualToAnchor(statusLabel.topAnchor, constant: -padding)
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
    
    // MARK: - Interface Builder
    
    override func prepareForInterfaceBuilder() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "appculture", inBundle: bundle, compatibleWithTraitCollection: traitCollection)
        logoImage.image = image
    }
    
}

extension UIColor {
    
    // MARK: - HEX Color
    
    convenience init (hex: String) {
        var colorString: String = hex
        if (hex.hasPrefix("#")) {
            let index = hex.startIndex.advancedBy(1)
            colorString = colorString.substringFromIndex(index)
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: colorString).scanHexInt(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
