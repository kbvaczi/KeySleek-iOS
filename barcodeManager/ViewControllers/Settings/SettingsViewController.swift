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

// MARK: - Form setup
extension SettingsViewController {
    
    func setupForm() {
        form
            +++ Section("Configuration")
            <<< maxNumberOfCardsDisplayRow()
            <<< barcodesEditableToggleRow()
            +++ Section("Donate Now")
            <<< donationsRow()
    }
    
    func barcodesEditableToggleRow() -> SwitchRow {
        let row = SwitchRow("Custom barcodes") { row in      // initializer
            row.tag = barcodesEditableToggleRowTag
            row.title = "Custom barcodes"
            row.value = AppManager.instance.settings.toAllowBarcodeEditing
            row.disabled = Condition.function([], { form in
                return !AppManager.instance.settings.isAppUnlocked
            })
            }.onChange { row in
                if let newValue = row.value {
                    AppManager.instance.settings.toAllowBarcodeEditing = newValue
                }
            }.onCellSelection { cell, row in
                if !AppManager.instance.settings.isAppUnlocked {
                    self.presentCustomBarcodesPopup()
                }
            }
        return row
    }
    private var barcodesEditableToggleRowTag: String { return "barcodesEditableToggleRow" }
    
    func maxNumberOfCardsDisplayRow() -> TextRow {
        let row = TextRow("Max number of cards") { row in
            row.tag = maxNumberOfCardsDisplayRowTag
            row.title = "Max number of cards"
            row.value = String(AppManager.instance.settings.maxNumberOfCards)
            row.disabled = true
            }.onCellSelection { cell, row in
                if !AppManager.instance.settings.isAppUnlocked {
                    self.presentCardLimitReachedPopup()
                }
            }.cellUpdate { cell, row in
                row.value = String(AppManager.instance.settings.maxNumberOfCards)
            }
        return row
    }
    private var maxNumberOfCardsDisplayRowTag: String { return "maxNumberOfCardsDisplayRow" }
    
    func donationsRow() -> DonateRow {
        let row = DonateRow()
        return row
    }
    
    func updateForm() {        
        self.form.rowBy(tag: self.barcodesEditableToggleRowTag)?.evaluateDisabled()
        self.form.rowBy(tag: self.maxNumberOfCardsDisplayRowTag)?.updateCell()
        self.form.rowBy(tag: self.maxNumberOfCardsDisplayRowTag)?.updateCell()
    }
    
}

// MARK: - Static extension
extension SettingsViewController {
    
    static func donatePitchString() -> String {
        return "Make a donation to support this app and access additional functionality."
    }
    
    static func cardLimitReachedPopup() -> UIAlertController {
        let popup = UIAlertController(title: "Need to store more cards?",
                                      message: SettingsViewController.donatePitchString(),
                                      preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return popup
    }
    
    static func customBarcodesPopup() -> UIAlertController {
        let popup = UIAlertController(title: "Need custom barcodes?",
                                      message: "With custom barcodes you can edit existing barcodes or create barcodes from scratch. \(SettingsViewController.donatePitchString())",
            preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return popup
    }
    
    static func thanksForDonatingPopup() -> UIAlertController {
        let popup = UIAlertController(title: "Thanks!",
                                      message: "We appreciate your donation and hope you continue to enjoy the app.",
            preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return popup
    }
    
}

// MARK: - Misc functions
extension SettingsViewController {
    
    func presentCustomBarcodesPopup() {
        self.present(SettingsViewController.customBarcodesPopup(), animated: true, completion: nil)
    }
    
    func presentCardLimitReachedPopup() {
        self.present(SettingsViewController.cardLimitReachedPopup(), animated: true, completion: nil)
    }
    
}
