//
//  ProgressBarButton.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/24/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import FontAwesome_swift

class ProgressBarButton: UIView, NibLoadable {
    
    /// Change name to distinguish multiple ProgressBarButtons on the same view
    @IBInspectable var name: String? = nil
    
    /// Set delegate to receive progress complete callback
    var delegate: ProgressBarButtonDelegate? = nil
    
    static let nibName = "ProgressBarButton"

    @IBOutlet weak var button: RoundButton!
    @IBAction func buttonTouchDown(_ sender: Any) { beginProgress() }
    @IBAction func buttonTouchUpInside(_ sender: Any) { resetProgress() }
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var pressHoldLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        self.button.delegate = self
        initProgressBar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        self.button.delegate = self
        initProgressBar()
    }
    
}

extension ProgressBarButton {
    
    private func initProgressBar() {
        progressBar.showValueString = false
        progressBar.value = 0
        progressBar.maxValue = 100
        progressBar.progressAngle = 100
        progressBar.emptyLineWidth = 0
        progressBar.emptyLineColor = .clear
        progressBar.showValueString = false
        progressBar.showUnitString = false
        progressBar.progressLineWidth = 10
        progressBar.progressStrokeColor = .clear
        progressBar.emptyLineStrokeColor = .clear
    }
    
    /// Setup button as a FontAwesome icon
    ///
    /// - Parameters:
    ///   - iconName: FontAwesome icon name
    ///   - iconStyle: FontAwesome icon style
    ///   - iconColor: FontAwesome icon color
    public func setupButton(iconName: FontAwesome, iconStyle: FontAwesomeStyle = .solid, iconColor: UIColor = .white, buttonStyle: RoundButton.Style = .default, labelColor: UIColor = .black) {
        
        self.button.setupButton(iconName: iconName, iconStyle: iconStyle, iconColor: iconColor, buttonStyle: buttonStyle)
        self.progressBar.progressColor = self.button.backgroundColor
        self.progressBar.alpha = self.button.alpha
        self.pressHoldLabel.textColor = labelColor
    }
    
    /// Function called when button pressed
    private func beginProgress() {
        
        UIImpactFeedbackGenerator().impactOccurred()
        pressHoldLabel.alpha = 0
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressBar.value = 100
        }, completion: { (didFinish: Bool) -> Void in
            if didFinish {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.delegate?.onProgressBarButtonComplete(name: self.name)
            }
        })

    }
    
    /// Function called when button is no long pressed
    private func resetProgress() {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.progressBar.value = 0
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 1.5, animations: { () -> Void in
                self.pressHoldLabel.alpha = 1
            })
            self.delegate?.onProgressBarButtonReset(name: self.name)
        })
        
    }
    
}

extension ProgressBarButton: RoundButtonDelegate {
    
    func touchExited() {
        self.resetProgress()
    }
    
}

protocol ProgressBarButtonDelegate {
    
    /// Function called when ProgressBarButton completes progress
    ///
    /// - Parameter name: name of ProgressBarButton that completed progress
    func onProgressBarButtonComplete(name: String?)
    
    /// Function called when ProgressBarButton progress has been reset
    ///
    /// - Parameter name: Name of ProgressBarButton that progress was reset on
    func onProgressBarButtonReset(name: String?)

}
