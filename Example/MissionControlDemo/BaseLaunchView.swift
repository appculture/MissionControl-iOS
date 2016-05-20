//
//  BaseLaunchView.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

@IBDesignable
class BaseLaunchView: UIView {
    
    // MARK: - Outlets
    
    let gradient = UIView()
    let gradientLayer = CAGradientLayer()

    let button = UIView()
    let buttonImage = UIImageView()
    let buttonTitle = UILabel()
    
    let statusLabel = UILabel()
    let statusLight = UIView()
    
    let countdown = UILabel()
    
    // MARK: - Properties
    
    var padding: CGFloat = 24.0
    
    var buttonHighlightColor = UIColor.lightGrayColor()
    var buttonColor = UIColor.whiteColor() {
        didSet {
            button.backgroundColor = buttonColor
        }
    }
    var buttonTitleColor = UIColor.darkGrayColor() {
        didSet {
            buttonTitle.textColor = buttonTitleColor
        }
    }
    
    var statusColor = UIColor.darkGrayColor() {
        didSet {
            button.layer.borderColor = statusColor.CGColor
            statusLight.backgroundColor = statusColor
        }
    }
    var statusTextColor = UIColor.whiteColor() {
        didSet {
            statusLabel.textColor = statusTextColor
            statusLight.layer.borderColor = statusTextColor.CGColor
        }
    }
    
    var countdownColor = UIColor.whiteColor() {
        didSet {
            countdown.textColor = countdownColor
        }
    }
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if touchesInsideView(touches, view: button) {
            highlightButton()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        if !touchesInsideView(touches, view: button) {
            restoreButton()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if touchesInsideView(touches, view: button) {
            restoreButton()
        }
    }
    
    private func touchesInsideView(touches: Set<UITouch>, view: UIView) -> Bool {
        guard let touch = touches.first else { return false }
        let location = touch.locationInView(view)
        let insideView = CGRectContainsPoint(view.bounds, location)
        return insideView
    }
    
    private func highlightButton() {
        UIView.animateWithDuration(0.2, animations: { [unowned self] in
            self.button.backgroundColor = self.buttonHighlightColor
            self.buttonImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        })
    }
    
    private func restoreButton() {
        UIView.animateWithDuration(0.2, animations: { [unowned self] in
            self.button.backgroundColor = self.buttonColor
            self.buttonImage.transform = CGAffineTransformIdentity
        })
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = buttonColor
        button.layer.borderColor = statusColor.CGColor
        button.layer.borderWidth = 10.0
        button.layer.cornerRadius = 10.0
        button.clipsToBounds = true

        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.contentMode = .ScaleAspectFill
        buttonImage.image = UIImage(named: "appculture")
        
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        buttonTitle.adjustsFontSizeToFitWidth = true
        buttonTitle.textAlignment = .Center
        buttonTitle.textColor = buttonTitleColor
        buttonTitle.text = "BUTTON"
    }
    
    private func configureStatus() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.setContentHuggingPriority(251.0, forAxis: .Vertical)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.textAlignment = .Center
        statusLabel.textColor = statusTextColor
        statusLabel.text = "STATUS"
        
        statusLight.translatesAutoresizingMaskIntoConstraints = false
        statusLight.backgroundColor = statusColor
        statusLight.layer.borderColor = statusTextColor.CGColor
        statusLight.layer.borderWidth = 2.0
        statusLight.layer.cornerRadius = 16.0
    }
    
    private func configureCountdown() {
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.adjustsFontSizeToFitWidth = true
        countdown.textAlignment = .Center
        countdown.textColor = countdownColor
        countdown.text = "00"
    }
    
    // MARK: - Configure Layout
    
    private func configureHierarchy() {
        button.addSubview(buttonImage)
        button.addSubview(buttonTitle)
        
        gradient.addSubview(button)
        gradient.addSubview(statusLabel)
        gradient.addSubview(statusLight)
        gradient.addSubview(countdown)
        
        addSubview(gradient)
    }
    
    override func updateConstraints() {
        removeConstraints(constraints)
        addConstraints(allConstraints)
        super.updateConstraints()
    }
    
    // MARK: - Constraints
    
    private var allConstraints: [NSLayoutConstraint] {
        var constraints = gradientConstraints
        constraints += buttonConstraints + buttonImageConstraints + buttonTitleConstraints
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
    
    private var buttonImageConstraints: [NSLayoutConstraint] {
        let leading = buttonImage.leadingAnchor.constraintEqualToAnchor(button.leadingAnchor, constant: 20.0)
        let top = buttonImage.topAnchor.constraintEqualToAnchor(button.topAnchor, constant: 22.0)
        let bottom = buttonImage.bottomAnchor.constraintEqualToAnchor(button.bottomAnchor, constant: -22.0)
        let width = buttonImage.widthAnchor.constraintEqualToAnchor(buttonImage.heightAnchor)
        return [leading, top, bottom, width]
    }
    
    private var buttonTitleConstraints: [NSLayoutConstraint] {
        let leading = buttonTitle.leadingAnchor.constraintEqualToAnchor(buttonImage.trailingAnchor, constant: 12.0)
        let trailing = buttonTitle.trailingAnchor.constraintEqualToAnchor(button.trailingAnchor, constant: -22.0)
        let centerY = buttonTitle.centerYAnchor.constraintEqualToAnchor(button.centerYAnchor)
        return [leading, trailing, centerY]
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
        let leading = countdown.leadingAnchor.constraintEqualToAnchor(leadingAnchor)
        let trailing = countdown.trailingAnchor.constraintEqualToAnchor(trailingAnchor)
        let top = countdown.topAnchor.constraintEqualToAnchor(topAnchor)
        let bottom = countdown.bottomAnchor.constraintEqualToAnchor(statusLight.topAnchor)
        return [leading, trailing, top, bottom]
    }
    
    // MARK: - Interface Builder
    
    override func prepareForInterfaceBuilder() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "appculture", inBundle: bundle, compatibleWithTraitCollection: traitCollection)
        buttonImage.image = image
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
