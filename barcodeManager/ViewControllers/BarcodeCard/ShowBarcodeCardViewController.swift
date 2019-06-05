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

    @IBOutlet weak var titleLabel: UILabel!
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
        updateView()
        initBackButton()
        setBackground()
        
        //Register observer for app to enter background
        NotificationCenter.default.addObserver(self, selector: #selector(resetBrightness),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        
        //Register observer for app to return from background
        NotificationCenter.default.addObserver(self, selector: #selector(increaseBrightness),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        increaseBrightness()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        resetBrightness()
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
        UIScreen.main.brightness = baselineBrightness
    }
    
    @objc func increaseBrightness() {
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
        self.titleLabel.text = (barcodeCard.photo == nil) ? barcodeCard.title : nil
        self.accountLabel.text = barcodeCard.account
        
        barcodeCard.loadPhotoFromFile(callBack: { loadedPhoto in
            self.photoImageView.image = loadedPhoto
            self.photoImageView.roundCornersForAspectFit(radius: 20)
        })
        
        guard let codeType = barcodeCard.codeType else { return }
        switch codeType {
        case .QR:
            self.qrCodeImageView.image = barcodeCard.barcodeImage
            if barcodeCard.account != nil {
                addBackground(to: barcodeWrapperView)
            } else {
                addBackground(to: qrCodeImageView)
            }
        default:
            self.barcodeImageView.image = barcodeCard.barcodeImage
            if barcodeCard.account != nil {
                addBackground(to: barcodeWrapperView)
            } else {
                addBackground(to: barcodeImageView)
            }
        }
        
    }
    
    private func setBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    private func addBackground(to fgView: UIView, outSet: CGFloat = 18) {
        
        guard fgView.isDescendant(of: self.view) else { return }
        
        //TODO: why does frame not line up? have to add 22 to dy?
        let bounds = fgView.bounds.insetBy(dx: -outSet, dy: -outSet).offsetBy(dx: 0, dy: 22)
        let frame = self.view.subviews.contains(fgView.superview!) ? self.view.convert(bounds, from: fgView.superview!) : self.view.convert(bounds, from: fgView)
        let bgView = UIView(frame: frame)
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 20
        view.insertSubview(bgView, at: 0)
    }
    
}

extension ShowBarcodeCardViewController: ProgressBarButtonDelegate {
    
    func onProgressBarButtonComplete(name: String?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onProgressBarButtonReset(name: String?) { }
    
}
