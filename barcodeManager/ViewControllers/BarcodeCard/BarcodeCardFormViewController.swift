//
//  BarcodeCardFormViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

class BarcodeCardFormViewController: FormViewController {
    
    var barcodeCard: BarcodeCard?
    
    var scanSegueIdentifier = "ScanSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }

}

extension BarcodeCardFormViewController {
    
    func setupForm() {
        
        form +++ Section("General")
            <<< TextRow(){ row in
                row.title = "Name"
                row.tag = "Name"
                row.placeholder = "Enter name"
                row.value = barcodeCard?.title
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.onChange { row in
                self.barcodeCard?.title = row.value
            }.cellUpdate { cell, row in
                if !row.isValid { cell.titleLabel?.textColor = .red }
            }
            <<< ImageCropRow() { row in
                row.title = "Front Photo"
                row.allowEditor = false
                row.value = barcodeCard?.photo
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.placeholderImage = UIImage.fontAwesomeIcon(name: .camera,
                                                               style: .solid,
                                                               textColor: .lightGray,
                                                               size: CGSize(width: 160, height: 80))
            }.cellSetup { (cell, row) in
                cell.height = ( { return 80 } )
            }.onChange { row in
                self.barcodeCard?.photo = row.value
            }.cellUpdate { cell, row in
                if !row.isValid { cell.textLabel?.textColor = .red }
            }
            <<< TextRow(){ row in
                row.title = "Account"
                row.tag = "Account"
                row.placeholder = "Add account number"
                row.value = barcodeCard?.account
                row.validationOptions = .validatesOnChange
                }.onChange { row in
                    self.barcodeCard?.account = row.value
                }
            +++ Section("Barcode")
            <<< BarcodeImageRow() { row in
                row.tag = "barcodeImage"
                if self.barcodeCard != nil { row.value = self.barcodeCard?.barcodeImage }
            }.onCellSelection { cell, row in
                self.performSegue(withIdentifier: self.scanSegueIdentifier, sender: nil)
            }.cellSetup { (cell, row) in
                cell.height = ( { return row.value?.size.height ?? 75 } )
            }.onChange { row in
                row.cell.height = ( { return row.value?.size.height ?? 75 } )
            }
            <<< TextRow(){ row in
                row.title = "Data"
                row.tag = "barcodeData"
                row.value = self.barcodeCard?.code
                row.hidden = Condition.function([], { form in
                    return !AppManager.instance.settings.toAllowBarcodeEditing
                })
            }.onChange { row in
                if  let newCode = row.value,
                    self.barcodeCard != nil {
                    self.barcodeCard?.code = newCode
                    if let imageRow = self.form.rowBy(tag: "barcodeImage") as? BarcodeImageRow {
                        imageRow.value = self.barcodeCard?.barcodeImage
                        imageRow.updateCell()
                    }
                }
            }
            <<< PushRow<BarcodeCards.barcodeType>() { row in
                row.title = "Type"
                row.tag = "barcodeType"
                row.options = BarcodeCards.barcodeType.allCases
                row.hidden = Condition.function([], { form in
                    return !AppManager.instance.settings.toAllowBarcodeEditing
                })
                if let codeTypeString = self.barcodeCard?.codeTypeString {
                    row.value = BarcodeCards.barcodeType(rawValue: codeTypeString)
                }
            }.onChange { row in
                if  let newCodeTypeString = row.value?.rawValue,
                    self.barcodeCard != nil {
                    self.barcodeCard?.codeTypeString = newCodeTypeString
                    if let imageRow = self.form.rowBy(tag: "barcodeImage") as? BarcodeImageRow {
                        imageRow.value = self.barcodeCard?.barcodeImage
                        imageRow.updateCell()
                    }
                }
            }.cellUpdate { cell, row in
                if !row.isValid { cell.textLabel?.textColor = .red }
            }
            +++ Section("Notes")
            <<< TextAreaRow() { row in
                row.tag = "notes"
                row.placeholder = "Add notes here"
                row.value = barcodeCard?.notes
                row.textAreaHeight = .dynamic(initialTextViewHeight: 50)
            }.onChange { row in
                self.barcodeCard?.notes = row.value
            }
            // Extra space for circular button at the bottom of form
            +++ Section("") { section in
                section.header?.height = { 100.0 }
            }
        
    }
    
    func displayValidationErrorPopup() {
        
        let alert = UIAlertController(title: "Missing fields", message: "Please fill out required fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ScanViewController {
            destination.delegate = self
        }
    }
    
}

extension BarcodeCardFormViewController: BarcodeScanDelegate {
    
    func didScanBarcode(withCode code: String, ofType codeType: BarcodeCards.barcodeType) {
        self.barcodeCard?.codeTypeString = codeType.rawValue
        self.barcodeCard?.code = code
        if let imageRow = self.form.rowBy(tag: "barcodeImage") as? BarcodeImageRow {
            imageRow.value = self.barcodeCard?.barcodeImage
            imageRow.updateCell()
        }
        if let dataRow = self.form.rowBy(tag: "barcodeData") as? TextRow {
            print("yes")
            dataRow.value = code
            dataRow.updateCell()
        }
        if let typeRow = self.form.rowBy(tag: "barcodeType") as? PushRow<BarcodeCards.barcodeType> {
            typeRow.value = codeType
            typeRow.updateCell()
        }
    }
    
}
