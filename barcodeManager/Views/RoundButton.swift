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
    var buttonStyle: UIAlertAction.Style = UIAlertAction.Style.default {
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
    
    convenience init(frame: CGRect, style: UIAlertAction.Style) {
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
        }
    }
    
    /// Setup button as a FontAwesome icon
    ///
    /// - Parameters:
    ///   - iconName: FontAwesome icon name
    ///   - iconStyle: FontAwesome icon style
    ///   - iconColor: FontAwesome icon color
    public func setButtonIcon(iconName: FontAwesome, iconStyle: FontAwesomeStyle = .solid,
                              iconColor: UIColor = .white) {
        
        let bgImage = UIImage.fontAwesomeIcon(name: iconName,
                                              style: iconStyle,
                                              textColor: iconColor,
                                              size: CGSize(width: 50, height: 50))
        
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
    
}

protocol RoundButtonDelegate {
    
    func touchExited()
    
}
