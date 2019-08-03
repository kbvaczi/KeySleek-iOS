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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.updateBarcode() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension EditBarcodeCardViewController {
    
    
    func updateBarcode() -> Bool  {
        
        guard let updatedBarcodeCard = self.barcodeCard else { return false }
        
        let validationError = self.form.validate()
        
        if validationError.count > 0 {
            print("invalid form")
            displayValidationErrorPopup()
            return false
        }
        
        BarcodeCards.instance.update(updatedBarcodeCard) { didSave in
            if didSave {
                DispatchQueue.main.async {
                    let i = self.navigationController?.viewControllers.index(of: self)
                    let previousViewController = self.navigationController?.viewControllers[i!-1]
                    if let showVC = previousViewController as? ShowBarcodeCardViewController {
                        showVC.barcodeCard = updatedBarcodeCard
                    }
                    self.navigationController?.popViewController(animated: true)
                }                
            }
        }
        return true
    }
    
}
