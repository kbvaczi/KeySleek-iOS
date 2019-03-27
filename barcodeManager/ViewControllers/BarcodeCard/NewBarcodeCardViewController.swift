//
//  NewBarcodeCardViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka

class NewBarcodeCardViewController: BarcodeCardFormViewController {
    
    @IBOutlet weak var saveButton: ProgressBarButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.barcodeCard == nil {
            self.barcodeCard = BarcodeCard()
        }
        initButtons()        
    }
    
}

extension NewBarcodeCardViewController {
    
    func initButtons() {
        saveButton.setupButton(iconName: .check, iconStyle: .solid, iconColor: .white, buttonStyle: .default)
        saveButton.delegate = self
        self.view.bringSubviewToFront(saveButton)
    }
    
    func saveBarcode() -> Bool {
        guard let barcodeToSave = self.barcodeCard else { return false }
        let validationError = self.form.validate()
        if validationError.count > 0 {
            print("invalid form")
            return false
        }
        if BarcodeCards.instance.add(barcodeToSave) {
            self.navigationController?.popViewController(animated: true)
        }
        return true
    }
    
}

extension NewBarcodeCardViewController: ProgressBarButtonDelegate {
 
    func onProgressBarButtonComplete(name: String?) {
        if self.saveBarcode() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onProgressBarButtonReset(name: String?) { }
    
}
