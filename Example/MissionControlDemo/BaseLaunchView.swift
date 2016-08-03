//
// BaseLaunchView.swift
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

@IBDesignable
class BaseLaunchView: UIView {
    
    // MARK: - Outlets
    
    let gradient = UIView()
    let gradientLayer = CAGradientLayer()

    let button = UIView()
    let buttonImage = UIImageView()
    let buttonTitle = UILabel()
    
    let statusTitle = UILabel()
    let statusLight = UIView()
    
    let countdown = UILabel()
    
    // MARK: - Properties
    
    var didTapButtonAction: ((sender: AnyObject) -> Void)?
    
    var padding: CGFloat = 24.0
    
    var buttonHighlightColor = UIColor.lightGray
    var buttonColor = UIColor.white {
        didSet {
            button.backgroundColor = buttonColor
        }
    }
    var buttonTitleColor = UIColor.darkGray {
        didSet {
            buttonTitle.textColor = buttonTitleColor
        }
    }
    
    var statusLightColor = UIColor.darkGray {
        didSet {
            statusLight.backgroundColor = statusLightColor
        }
    }
    var statusTitleColor = UIColor.white {
        didSet {
            statusTitle.textColor = statusTitleColor
            statusLight.layer.borderColor = statusTitleColor.cgColor
        }
    }
    
    var countdownColor = UIColor.white {
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
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    func commonInit() {
        configureOutlets()
        configureHierarchy()
        updateConstraints()
    }
    
    // MARK: - Override
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = gradient.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if touchesInsideView(touches, view: button) {
            highlightButton()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if !touchesInsideView(touches, view: button) {
            restoreButton()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if touchesInsideView(touches, view: button) {
            restoreButton()
            if let action = didTapButtonAction {
                action(sender: button)
            }
        }
    }
    
    private func touchesInsideView(_ touches: Set<UITouch>, view: UIView) -> Bool {
        guard let touch = touches.first else { return false }
        let location = touch.location(in: view)
        let insideView = view.bounds.contains(location)
        return insideView
    }
    
    private func highlightButton() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.button.backgroundColor = self.buttonHighlightColor
            self.buttonImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        })
    }
    
    private func restoreButton() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.button.backgroundColor = self.buttonColor
            self.buttonImage.transform = CGAffineTransform.identity
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
        gradient.layer.insertSublayer(gradientLayer, at: 0)
        
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.blue.cgColor]
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.drawsAsynchronously = true
        gradientLayer.needsDisplayOnBoundsChange = true
        gradientLayer.setNeedsDisplay()
    }
    
    private func configureButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = buttonColor
        button.layer.borderColor = statusLightColor.cgColor
        button.layer.borderWidth = 10.0
        button.layer.cornerRadius = 10.0
        button.clipsToBounds = true

        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.contentMode = .scaleAspectFill
        buttonImage.image = UIImage(named: "appculture")
        
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        buttonTitle.adjustsFontSizeToFitWidth = true
        buttonTitle.textAlignment = .center
        buttonTitle.textColor = buttonTitleColor
        buttonTitle.text = "BUTTON"
    }
    
    private func configureStatus() {
        statusTitle.translatesAutoresizingMaskIntoConstraints = false
        statusTitle.setContentHuggingPriority(251.0, for: .vertical)
        statusTitle.adjustsFontSizeToFitWidth = true
        statusTitle.textAlignment = .center
        statusTitle.textColor = statusTitleColor
        statusTitle.text = "STATUS"
        
        statusLight.translatesAutoresizingMaskIntoConstraints = false
        statusLight.backgroundColor = statusLightColor
        statusLight.layer.borderColor = statusTitleColor.cgColor
        statusLight.layer.borderWidth = 2.0
        statusLight.layer.cornerRadius = 16.0
    }
    
    private func configureCountdown() {
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.adjustsFontSizeToFitWidth = true
        countdown.textAlignment = .center
        countdown.textColor = countdownColor
        countdown.text = "00"
    }
    
    // MARK: - Configure Layout
    
    private func configureHierarchy() {
        button.addSubview(buttonImage)
        button.addSubview(buttonTitle)
        
        gradient.addSubview(button)
        gradient.addSubview(statusTitle)
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
        constraints += statusTitleConstraints + statusLightConstraints
        constraints += countdownConstraints
        return constraints
    }
    
    private var gradientConstraints: [NSLayoutConstraint] {
        let leading = gradient.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailing = gradient.trailingAnchor.constraint(equalTo: trailingAnchor)
        let top = gradient.topAnchor.constraint(equalTo: topAnchor)
        let bottom = gradient.bottomAnchor.constraint(equalTo: bottomAnchor)
        return [leading, trailing, top, bottom]
    }
    
    private var buttonConstraints: [NSLayoutConstraint] {
        let leading = button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding)
        let trailing = button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        let bottom = button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        let height = button.heightAnchor.constraint(equalToConstant: 90.0)
        return [leading, trailing, bottom, height]
    }
    
    private var buttonImageConstraints: [NSLayoutConstraint] {
        let leading = buttonImage.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20.0)
        let top = buttonImage.topAnchor.constraint(equalTo: button.topAnchor, constant: 22.0)
        let bottom = buttonImage.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -22.0)
        let width = buttonImage.widthAnchor.constraint(equalTo: buttonImage.heightAnchor)
        return [leading, top, bottom, width]
    }
    
    private var buttonTitleConstraints: [NSLayoutConstraint] {
        let leading = buttonTitle.leadingAnchor.constraint(equalTo: buttonImage.trailingAnchor, constant: 12.0)
        let trailing = buttonTitle.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -22.0)
        let centerY = buttonTitle.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        return [leading, trailing, centerY]
    }
    
    private var statusTitleConstraints: [NSLayoutConstraint] {
        let leading = statusTitle.leadingAnchor.constraint(equalTo: button.leadingAnchor)
        let trailing = statusTitle.trailingAnchor.constraint(equalTo: button.trailingAnchor)
        let bottom = statusTitle.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -padding)
        return [leading, trailing, bottom]
    }
    
    private var statusLightConstraints: [NSLayoutConstraint] {
        let centerX = statusLight.centerXAnchor.constraint(equalTo: centerXAnchor)
        let bottom = statusLight.bottomAnchor.constraint(equalTo: statusTitle.topAnchor, constant: -padding)
        let width = statusLight.widthAnchor.constraint(equalToConstant: 32.0)
        let height = statusLight.heightAnchor.constraint(equalToConstant: 32.0)
        return [centerX, bottom, width, height]
    }
    
    private var countdownConstraints: [NSLayoutConstraint] {
        let leading = countdown.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailing = countdown.trailingAnchor.constraint(equalTo: trailingAnchor)
        let top = countdown.topAnchor.constraint(equalTo: topAnchor)
        let bottom = countdown.bottomAnchor.constraint(equalTo: statusLight.topAnchor)
        return [leading, trailing, top, bottom]
    }
    
    // MARK: - Interface Builder
    
    override func prepareForInterfaceBuilder() {
        let bundle = Bundle(for: self.dynamicType)
        let image = UIImage(named: "appculture", in: bundle, compatibleWith: traitCollection)
        buttonImage.image = image
    }
    
}

extension UIColor {
    
    // MARK: - HEX Color
    
    convenience init (hex: String) {
        var colorString: String = hex
        if (hex.hasPrefix("#")) {
            let index = hex.characters.index(hex.startIndex, offsetBy: 1)
            colorString = colorString.substring(from: index)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
