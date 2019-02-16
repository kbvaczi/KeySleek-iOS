//
//  ViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/26/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation

class ScanViewController: RSCodeReaderViewController {
    
    var codeHasBeenScanned: Bool = false
    var barcodeCard: BarcodeCard?

    override func viewWillAppear(_ animated: Bool) {
        self.codeHasBeenScanned = false // reset the flag so user can do another scan
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.red.cgColor
        
        self.cornersLayer.strokeColor = UIColor.yellow.cgColor
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }
        
        self.barcodesHandler = { barcodes in
            guard !self.codeHasBeenScanned else { return }
            for barcode in barcodes {
                guard   let codeValue = barcode.stringValue else { continue }
                self.codeHasBeenScanned = true
                let stringToPrint = "Barcode found: type=" + barcode.type.rawValue + " value=" + codeValue
                print(stringToPrint)
                self.barcodeCard = BarcodeCard(title: nil,
                                               code: codeValue,
                                               codeType: BarcodeCards.barcodeType(rawValue: barcode.type.rawValue)!)
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "NewBarcodeCardSegue", sender: self)
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
//        imageView.center = self.view.center
        self.view.addSubview(imageView)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewBarcodeCardSegue" {
            if  let destination = segue.destination as? NewBarcodeCardViewController,
                self.barcodeCard != nil {
                destination.barcodeCard = barcodeCard
            }
        }
    }

}

