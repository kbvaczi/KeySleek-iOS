//
//  ShowBarcodeCardViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/30/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import AVFoundation
import FontAwesome_swift

class ShowBarcodeCardViewController: UIViewController {

    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var backButton: ProgressBarButton!
    @IBOutlet weak var barcodeWrapperView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    
    var barcodeCard: BarcodeCard?
    var baselineBrightness: CGFloat = UIScreen.main.brightness
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        updateView()
        initBackButton()
        addBlurBackground(to: self.view, style: .dark)
        self.modalPresentationCapturesStatusBarAppearance = true
        
        //Register observer for app to enter background
        NotificationCenter.default.addObserver(self, selector: #selector(resetBrightness),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        
        //Register observer for app to return from background
        NotificationCenter.default.addObserver(self, selector: #selector(increaseBrightness),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        increaseBrightness()
        self.barcodeWrapperView.backgroundColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        resetBrightness()
        self.barcodeWrapperView.backgroundColor = UIColor.clear        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditBarcodeCardSegueIdentifier" {
            guard let destination = segue.destination as? EditBarcodeCardViewController else {
                return
            }
            destination.barcodeCard = self.barcodeCard
        }
    }
    
    @objc func resetBrightness() {
        guard AppManager.instance.settings.toIncreaseBrightnessForBarcodes else { return }
        UIScreen.main.brightness = baselineBrightness
    }
    
    @objc func increaseBrightness() {
        guard AppManager.instance.settings.toIncreaseBrightnessForBarcodes else { return }
        UIScreen.main.brightness = 1.0
    }
    
}

extension ShowBarcodeCardViewController {
   
    private func initBackButton() {
        backButton.setupButton(iconName: .home, labelColor: .white)
        backButton.delegate = self
    }
    
    private func updateView() {
        guard let barcodeCard = self.barcodeCard else { return }
        
        self.accountLabel.text = barcodeCard.account
        
        self.photoImageView.image = barcodeCard.photo
        self.photoImageView.roundCornersForAspectFit(radius: 20)
        barcodeWrapperView.layer.cornerRadius = 20
                
        guard let codeType = barcodeCard.codeType else { return }
        switch codeType {
        case .QR:
            self.qrCodeImageView.image = barcodeCard.barcodeImage
        default:
            self.barcodeImageView.image = barcodeCard.barcodeImage
        }
        
    }
    
    private func addBlurBackground(to view: UIView, style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
}

extension ShowBarcodeCardViewController: ProgressBarButtonDelegate {
    
    func onProgressBarButtonComplete(name: String?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onProgressBarButtonReset(name: String?) { }
    
}
