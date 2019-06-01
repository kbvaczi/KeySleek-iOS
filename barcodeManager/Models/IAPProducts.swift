//
//  IAPProducts.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 5/17/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Foundation

/// Object to manage IAP products supported by this app
public struct IAPProducts {
    
    /// IAP Product for first donation level
    public static let donateLevel1 = "com.vaczoway.barcodeManager.donationLevel1"
    /// IAP Product for second donation level
    public static let donateLevel2 = "com.vaczoway.barcodeManager.donationLevel2"
    /// IAP Product for third donation level
    public static let donateLevel3 = "com.vaczoway.barcodeManager.donationLevel3"
    
    /// List of product identifiers supported in this app
    private static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.donateLevel1,                    IAPProducts.donateLevel2, IAPProducts.donateLevel3]
    
    /// Connection to IAPManager instance for StoreKit integration
    public static let store = IAPManager(productIds: IAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
