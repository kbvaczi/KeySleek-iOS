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
    
    var originalBarcodeCard: BarcodeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalBarcodeCard = self.barcodeCard
        form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Update"
                row.onCellSelection(self.updateBarcode)
        }
    }
    
    func updateBarcode(cell: ButtonCellOf<String>, row: ButtonRow)  {
        
        guard   let barcodeToUpdate = self.originalBarcodeCard,
                let newBarcodeCard = self.barcodeCard else { return }
        
        let validationError = self.form.validate()
        
        if validationError.count > 0 {
            print("invalid form")
            return
        }
        
        if BarcodeCards.instance.update(barcodeToUpdate, with: newBarcodeCard) {
            let i = navigationController?.viewControllers.index(of: self)
            let previousViewController = navigationController?.viewControllers[i!-1]
            if let showVC = previousViewController as? ShowBarcodeCardViewController {
                showVC.barcodeCard = newBarcodeCard
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
