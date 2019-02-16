//
//  BarcodeCardFormViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka

class BarcodeCardFormViewController: FormViewController {
    
    var barcodeCard: BarcodeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Name")
            <<< TextRow(){ row in
                row.placeholder = "Enter title here"
                row.value = barcodeCard?.title
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }.onChange { row in
                    self.barcodeCard?.title = row.value
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
            +++ Section()
            <<< BarcodeCardImageRow() { row in
                    row.tag = "barcodeImage"
                    if self.barcodeCard != nil {
                        row.value = self.barcodeCard!
                    }
                }
            +++ Section("Barcode Information")
            <<< TextAreaRow(){ row in
                row.title = "Data"
                row.tag = "data"
                row.add(rule: RuleRequired())
                row.value = self.barcodeCard?.code
//                row.disabled = true
                row.textAreaHeight = .dynamic(initialTextViewHeight: 20)
                }.onChange { row in
                    if  let newCode = row.value,
                        self.barcodeCard != nil {
                        self.barcodeCard?.code = newCode
                        if let imageRow = self.form.rowBy(tag: "barcodeImage") as? BarcodeCardImageRow {
                            imageRow.value = self.barcodeCard
                            imageRow.updateCell()
                        }
                    }
                }
            <<< PushRow<BarcodeCards.barcodeType>() { row in
                row.title = "Type"
                row.tag = "type"
                row.add(rule: RuleRequired())
                row.options = BarcodeCards.barcodeType.allCases
                if let codeTypeString = self.barcodeCard?.codeTypeString {
                    row.value = BarcodeCards.barcodeType(rawValue: codeTypeString)
                }
                }.onChange { row in
                    if  let newCodeTypeString = row.value?.rawValue,
                        self.barcodeCard != nil {
                        self.barcodeCard?.codeTypeString = newCodeTypeString
                        if let imageRow = self.form.rowBy(tag: "barcodeImage") as? BarcodeCardImageRow {
                            imageRow.value = self.barcodeCard
                            imageRow.updateCell()
                        }
                    }
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                }
    }
}
