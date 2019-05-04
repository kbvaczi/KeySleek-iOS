//
//  SettingsViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 5/4/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka

class SettingsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
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

extension SettingsViewController {
    
    func setupForm() {
        form
            +++ Section("Configuration")
            <<< maxNumberOfCardsDisplayRow()
            <<< barcodesEditableToggleRow()
        
    }
    
    func barcodesEditableToggleRow() -> SwitchRow {
        let row = SwitchRow("Allow editing barcodes") { row in      // initializer
            row.title = "Editable barcodes"
            row.value = AppManager.instance.settings.toAllowBarcodeEditing
            }.onChange { row in
                if let newValue = row.value {
                    AppManager.instance.settings.toAllowBarcodeEditing = newValue
                }
            }
        return row
    }
    
    func maxNumberOfCardsDisplayRow() -> TextRow {
        let row = TextRow("Max number of cards") { row in
            row.title = "Max number of cards"
            row.value = String(AppManager.instance.settings.maxNumberOfCards)
            row.disabled = true
        }
        return row
    }
    
}
