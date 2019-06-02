//
//  ViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/26/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import AVFoundation

class ScanViewController: RSCodeReaderViewController {
    
    @IBOutlet weak var cancelButton: ProgressBarButton!
    @IBOutlet weak var torchButton: RoundButton!
    @IBAction func toggleTorch(_ sender: Any) { let _ = toggleTorch() }
    
    var codeHasBeenScanned: Bool = false
    var delegate: BarcodeScanDelegate? = nil

    override func viewWillAppear(_ animated: Bool) {
        self.codeHasBeenScanned = false // reset the flag so user can do another scan
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
        setupCancelButton()
        setupTorchButton()
    }
    
}

extension ScanViewController {
    
    func setupScanner() {
        self.focusMarkLayer.strokeColor = UIColor.white.cgColor
        self.cornersLayer.strokeColor = UIColor.clear.cgColor
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }
        
        self.barcodesHandler = { barcodes in
            guard !self.codeHasBeenScanned else { return }
            for barcode in barcodes {
                guard   let codeValue = barcode.stringValue else { continue }
                self.codeHasBeenScanned = true
                let codeType = BarcodeCards.barcodeType(rawValue: barcode.type.rawValue)!
                DispatchQueue.main.async(execute: {
                    self.delegate?.didScanBarcode(withCode: codeValue, ofType: codeType)
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        let image = UIImage(named: "scanTarget")
        let imageFillScale: CGFloat = 0.7
        let imageWidth = min(self.view.frame.width * imageFillScale, self.view.frame.height * imageFillScale)
        let imageOrigin = CGPoint(x: self.view.center.x - imageWidth / 2, y: self.view.center.y - imageWidth / 2)
        let imageFrame = CGRect(origin: imageOrigin, size: CGSize(width: imageWidth, height: imageWidth))
        let imageView = UIImageView(frame: imageFrame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
    }
    
    func setupCancelButton() {
        cancelButton.setupButton(iconName: .undoAlt, iconStyle: .solid, iconColor: .white, buttonStyle: .cancel, labelColor: .white)
        cancelButton.delegate = self
    }
    
    func setupTorchButton() {
        torchButton.setupButton(iconName: .bolt, iconStyle: .solid, iconColor: .white, buttonStyle: .default)
        self.torchButton.isToggleButton = true
    }
    
}

extension ScanViewController: ProgressBarButtonDelegate {
    
    func onProgressBarButtonComplete(name: String?) {
        self.dismiss(animated: true)
    }
    
    func onProgressBarButtonReset(name: String?) { }
    
}

protocol BarcodeScanDelegate {

    func didScanBarcode(withCode code: String, ofType codeType: BarcodeCards.barcodeType)
    
}

