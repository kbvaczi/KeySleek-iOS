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
        checkForAbilityToAddMoreCards()
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
            displayValidationErrorPopup()
            return false
        }
        BarcodeCards.instance.add(barcodeToSave) { didSave in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }            
        }
        return true
    }
    
    func checkForAbilityToAddMoreCards() {
        
        let maxNumberOfCards = AppManager.instance.settings.maxNumberOfCards
        let currentNumberOfCards = BarcodeCards.instance.numberOfSavedCards()
        
        let popUp = UIAlertController(title: "Need to store more cards?",
                                      message: SettingsViewController.donatePitchString(),
                                      preferredStyle: .alert)
        popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        guard maxNumberOfCards > currentNumberOfCards else {
            self.navigationController?.popViewController(animated: true)
            self.performSegue(withIdentifier: "newToSettingsSegue", sender: nil)
            self.navigationController?.present(popUp, animated: true)
            return
        }
        
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
