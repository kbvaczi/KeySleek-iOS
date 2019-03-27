//
//  EditBarcodeCardViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/3/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka

class EditBarcodeCardViewController: BarcodeCardFormViewController {
    
    @IBOutlet weak var updateButton: ProgressBarButton!
    
    var originalBarcodeCard: BarcodeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.originalBarcodeCard = self.barcodeCard
        self.initButtons()
    }
    
}

extension EditBarcodeCardViewController {
    
    func initButtons() {
        updateButton.setupButton(iconName: .check, iconStyle: .solid, iconColor: .white, buttonStyle: .default)
        updateButton.delegate = self
        self.view.bringSubviewToFront(updateButton)
    }
    
    func updateBarcode() -> Bool  {
        
        guard   let barcodeToUpdate = self.originalBarcodeCard,
            let newBarcodeCard = self.barcodeCard else { return false }
        
        let validationError = self.form.validate()
        
        if validationError.count > 0 {
            print("invalid form")
            return false
        }
        
        if BarcodeCards.instance.update(barcodeToUpdate, with: newBarcodeCard) {
            let i = navigationController?.viewControllers.index(of: self)
            let previousViewController = navigationController?.viewControllers[i!-1]
            if let showVC = previousViewController as? ShowBarcodeCardViewController {
                showVC.barcodeCard = newBarcodeCard
            }
            self.navigationController?.popViewController(animated: true)
        }
        return true
    }
    
}

extension EditBarcodeCardViewController: ProgressBarButtonDelegate {
    
    func onProgressBarButtonComplete(name: String?) {
        if self.updateBarcode() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onProgressBarButtonReset(name: String?) { }
    
}
