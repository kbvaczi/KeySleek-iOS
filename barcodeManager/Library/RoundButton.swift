//
//  RoundButton.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 3/2/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import FontAwesome_swift

class RoundButton: UIButton {

    /// Style of button.  Follows UIAlertAction styles.
    var buttonStyle: RoundButton.Style = RoundButton.Style.default {
        didSet { setupButtonBackground() }
    }
    
    /// Determines whether the button is a simple press button or a toggle on/off
    var isToggleButton: Bool = false
    private var hasBeenToggled: Bool = false
    
    private var bgColor: UIColor = UIColor.blue
    private var bgColorSelected: UIColor = UIColor.darkGray
    
    var delegate: RoundButtonDelegate? = nil
    
    /// Prohibit defauilt initializer to force setting button style
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonBackground()
    }
    
    convenience init(frame: CGRect, style: RoundButton.Style) {
        self.init(frame: frame)
        self.buttonStyle = style
    }
    
    //MARK: use this to set background color of UIButton for highlighted state
    override open var isHighlighted: Bool {
        willSet {
            if newValue != isHighlighted && newValue == true {
                hasBeenToggled = !hasBeenToggled
            }
        }
        didSet {
            if isToggleButton {
                backgroundColor = hasBeenToggled ? self.bgColorSelected : self.bgColor
            } else {
                backgroundColor = isHighlighted ? self.bgColorSelected : self.bgColor
            }
            // handle swipe exit for delegate
            if isHighlighted == false { self.delegate?.touchExited() }
        }
    }
    
    enum Style: String {
        case `default` = "default"
        case destructive = "destructive"
        case cancel = "cancel"
        case custom = "custom"
    }

}

extension RoundButton {
    
    private func setupButtonBackground() {
        self.layer.cornerRadius = self.bounds.size.width / 2
        self.clipsToBounds = true
        self.alpha = 1
        
        switch buttonStyle {
        case .default:
            self.bgColor = .blue
            self.bgColorSelected = .darkGray
            self.backgroundColor = bgColor
        case .cancel:
            self.bgColor = .lightGray
            self.bgColorSelected = .darkGray
            self.backgroundColor = bgColor
        case .destructive:
            self.bgColor = .red
            self.bgColorSelected = .darkGray
            self.backgroundColor = bgColor
        case .custom:
            break
        }
    }
    
    /// Setup button as a FontAwesome icon
    ///
    /// - Parameters:
    ///   - iconName: FontAwesome icon name
    ///   - iconStyle: FontAwesome icon style
    ///   - iconColor: FontAwesome icon color
    public func setButtonIcon(iconName: FontAwesome, iconStyle: FontAwesomeStyle = .solid,
                              iconColor: UIColor = .white, size: CGSize = CGSize(width: 50, height: 50)) {
        
        let bgImage = UIImage.fontAwesomeIcon(name: iconName,
                                              style: iconStyle,
                                              textColor: iconColor,
                                              size: size)
        
        self.setImage(bgImage, for: .normal)
        self.setImage(bgImage, for: .highlighted)
        
    }
    
    /// Set background image for button
    ///
    /// - Parameter image: image to set as background
    public func setButtonImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
    }
    
    /// Set custom button colors.  Only works if button style is set to custom.
    ///
    /// - Parameters:
    ///   - bgColor: background color of button
    ///   - bgColorSelected: background color of button when selected
    ///   - tintColor: tint color of button
    public func setCustomButtonColors(bgColor: UIColor, bgColorSelected: UIColor, tintColor: UIColor) {
        if self.buttonStyle == .custom {
            self.bgColor = bgColor
            self.bgColorSelected = bgColorSelected
            self.tintColor = tintColor
            self.backgroundColor = bgColor
        }
    }
    
}

protocol RoundButtonDelegate {
    
    func touchExited()
    
}
