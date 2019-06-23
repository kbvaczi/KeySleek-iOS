//
//  ImageCropViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/17/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Eureka
import UIKit
import IGRPhotoTweaks

open class ImageCropViewController: IGRPhotoTweakViewController  {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var horizontalDial: HorizontalDial! {
        didSet {
            self.horizontalDial?.migneticOption = .none
            self.horizontalDial?.centerMarkWidth = 4.0
            self.horizontalDial?.maximumValue = 95
            self.horizontalDial?.minimumValue = -95
        }
    }
    
    @IBAction func cancelButtonTapped() {
        self.dismissAction()
    }
    
    @IBAction func saveButtonTapped() {
        self.cropAction()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
    }

}

extension ImageCropViewController: HorizontalDialDelegate {
    
    public func horizontalDialDidValueChanged(_ horizontalDial: HorizontalDial) {
        let degrees = horizontalDial.value
        let radians = IGRRadianAngle.toRadians(CGFloat(degrees))
        self.changeAngle(radians: radians)
    }
    
    public func horizontalDialDidEndScroll(_ horizontalDial: HorizontalDial) {
        self.stopChangeAngle()
    }
    
}

extension ImageCropViewController: UINavigationBarDelegate {
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    
}
