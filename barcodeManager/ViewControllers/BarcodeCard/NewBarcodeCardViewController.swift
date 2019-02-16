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
    
    override func viewDidLoad() {
        if self.barcodeCard == nil {
            self.barcodeCard = BarcodeCard(title: nil, code: "0123", codeType: .QR)
        }
        super.viewDidLoad()        
        self.navigationItem.backBarButtonItem?.title = "Scan Again"
        form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Save"
                row.onCellSelection(self.saveBarcode)
        }
    }
    
    func saveBarcode(cell: ButtonCellOf<String>, row: ButtonRow)  {
        guard let barcodeToSave = self.barcodeCard else { return }
        let validationError = self.form.validate()
        if validationError.count > 0 {
            print("invalid form")
            return
        }
        if BarcodeCards.instance.add(barcodeToSave) {
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
