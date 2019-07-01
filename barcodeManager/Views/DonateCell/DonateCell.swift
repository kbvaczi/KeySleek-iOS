//
//  DonateCell.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 5/12/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Eureka
import StoreKit

final class DonateCell: ButtonCell {
    
    @IBOutlet weak var donateButton1: RoundButton!
    @IBOutlet weak var donateButton2: RoundButton!
    @IBOutlet weak var donateButton3: RoundButton!
    @IBOutlet weak var alreadyDonatedButton: UIButton!
    @IBOutlet weak var unlockFeaturesLabel: UILabel!
    
    @IBAction func donateButton1Tapped(_ sender: RoundButton) {
        makePurchase(self.donateLevel1Product)
    }
    @IBAction func donateButton2Tapped(_ sender: RoundButton) {
        makePurchase(self.donateLevel2Product)
    }
    @IBAction func donateButton3Tapped(_ sender: RoundButton) {
        makePurchase(self.donateLevel3Product)
    }
    @IBAction func alreadyDonatedButtonTapped(_ sender: UIButton) {
        IAPProducts.store.restorePurchases()
    }
    
    private var donateLevel1Product: SKProduct? = nil
    private var donateLevel2Product: SKProduct? = nil
    private var donateLevel3Product: SKProduct? = nil
    
    override func setup() {
        super.setup()
        updateDonateButtons()
        initializeIAP()
        if AppManager.instance.settings.isAppUnlocked == true {
            unlockFeaturesLabel.alpha = 0
        }
    }
    
    override func update() {
        super.update()
        updateDonateButtons()
        if AppManager.instance.settings.isAppUnlocked == true {
            unlockFeaturesLabel.alpha = 0
        }
    }
    
}

extension DonateCell {
    
    private func updateDonateButtons() {
        donateButton1.setTitle("", for: .normal)
        donateButton2.setTitle("", for: .normal)
        donateButton3.setTitle("", for: .normal)
        
        if IAPProducts.store.isProductPurchased(IAPProducts.donateLevel1) {
            setButtonStylePurchased(donateButton1)
        } else {
            let bronzeColor = UIColor(displayP3Red: 225/255, green: 147/255, blue: 70/255, alpha: 1)
            donateButton1.setupButton(iconName: .trophy, iconStyle: .solid, iconColor: .white, buttonStyle: .custom, size: CGSize(width: 35, height: 34))
            donateButton1.setCustomButtonColors(bgColor: bronzeColor, bgColorSelected: .darkGray, tintColor: .white)
        }
        if IAPProducts.store.isProductPurchased(IAPProducts.donateLevel2) {
            setButtonStylePurchased(donateButton2)
        } else {
            let silverColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 210/255, alpha: 1)
            donateButton2.setupButton(iconName: .trophy, iconStyle: .solid, iconColor: .white, buttonStyle: .custom, size: CGSize(width: 43, height: 43))
            donateButton2.setCustomButtonColors(bgColor: silverColor, bgColorSelected: .darkGray, tintColor: .white)
        }
        if IAPProducts.store.isProductPurchased(IAPProducts.donateLevel3) {
            setButtonStylePurchased(donateButton3)
        } else {
            let goldColor = UIColor(displayP3Red: 252/255, green: 194/255, blue: 0, alpha: 1)
            donateButton3.setupButton(iconName: .trophy, iconStyle: .solid, iconColor: .white, buttonStyle: .custom, size: CGSize(width: 50, height: 50))
            donateButton3.setCustomButtonColors(bgColor: goldColor, bgColorSelected: .darkGray, tintColor: .white)
        }
    }
    
    private func setButtonStylePurchased(_ button: RoundButton) {
        let greenColor = UIColor(displayP3Red: 0, green: 200, blue: 0, alpha: 1)
        button.setupButton(iconName: .check, iconStyle: .solid, iconColor: .black, buttonStyle: .custom)
        button.setCustomButtonColors(bgColor: .white, bgColorSelected: .white, tintColor: greenColor )
        button.isUserInteractionEnabled = false
    }
    
}

// MARK: - StoreKit implementation
extension DonateCell {
    
    private func initializeIAP() {
        
        // Add observer to notify us when purchase has been made
        let selector = #selector(DonateCell.handlePurchaseNotification(_:))
        NotificationCenter.default.addObserver(self, selector: selector,
                                               name: .IAPManagerPurchaseNotification,
                                               object: nil)
        
        // Search available products on app store connect and assign those supported by this scene
        IAPProducts.store.requestProducts() { [weak self] success, products in
            guard let products = products else { return }
            for product in products {
                switch product.productIdentifier {
                case IAPProducts.donateLevel1:
                    self?.donateLevel1Product = product
                case IAPProducts.donateLevel2:
                    self?.donateLevel2Product = product
                case IAPProducts.donateLevel3:
                    self?.donateLevel3Product = product
                default:
                    break
                }
            }
        }
        
    }
    
    /// Checks whether product is available and initiates purchase
    ///
    /// - Parameter productToPurchase: product to purchase
    private func makePurchase(_ productToPurchase: SKProduct?) {
        if let product = productToPurchase {
            IAPProducts.store.buyProduct(product)
        } else {
            handleFailureNotification(nil)
        }
    }
    
    /// Performed after successful purchase
    ///
    /// - Parameter notification: notification
    @objc func handlePurchaseNotification(_ notification: Notification) {
        AppManager.instance.settings.isAppUnlocked = true
        self.update()
        (self.formViewController() as? SettingsViewController)?.updateForm()
    }
    
    /// Performed after unsuccessful purchase
    ///
    /// - Parameter error: error
    @objc func handleFailureNotification(_ error: NSError?) {
        guard let vc = self.formViewController() else { return }
        
        //TODO: disable user interaction while popup is being displayed
        
        let popup = UIAlertController(title: "Oops!", message: "There was a problem with your request, please try again later", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        vc.present(popup, animated: true, completion: nil)
        
    }
    
}

final class DonateRow: Row<DonateCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DonateCell>(nibName: "DonateCell")
        cell.height = { return 230 }
        self.disabled = Condition(booleanLiteral: true)
    }
    
}
