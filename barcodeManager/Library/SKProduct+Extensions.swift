//
//  SKProduct+Extensions.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 5/17/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import StoreKit

extension SKProduct {
    
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    var localizedPrice: String {
        if self.price == 0.00 {
            print("Retrieved price of product \(self.localizedTitle) = Free")
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale
            
            guard let formattedPrice = formatter.string(from: self.price)else {
                print("Error: unable to retrieve price for SKProduct \(self.localizedTitle)")
                return "Unknown Price"
            }
            
            print("Retrieved price of product \(self.localizedTitle) = \(formattedPrice)")
            
            return formattedPrice
        }
    }
    
}
