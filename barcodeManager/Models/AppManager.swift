//
//  AppManager.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 5/4/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Foundation

class AppManager {
    
    /// Singleton
    static let instance = AppManager()
    
    /// Application Settings
    var settings = AppSettings()
    
    /// Disallow instances of this class
    private init() { }
    
}

class AppSettings {
    
    /// When set to true, allows manually editing barcodes, default is false
    var toAllowBarcodeEditing: Bool = false {
        didSet {
            UserDefaults.standard.set(toAllowBarcodeEditing, forKey: toAllowBarcodeEditingKey)
        }
    }
    private let toAllowBarcodeEditingKey = "toAllowBarcodeEditing"
    
    //TODO: update max number of cards default to 5
    /// Maximum number of cards that can be created, default is 5
    var maxNumberOfCards: Int = 100 {
        didSet {
            UserDefaults.standard.set(maxNumberOfCards, forKey: maxNumberOfCardsKey)
        }
    }
    private let maxNumberOfCardsKey = "maxNumberOfCards"
    
    /// Disallow external instances of this class
    fileprivate init() {
        if UserDefaults.standard.value(forKey: toAllowBarcodeEditingKey) != nil {
            toAllowBarcodeEditing = UserDefaults.standard.bool(forKey: toAllowBarcodeEditingKey)
        }
        if UserDefaults.standard.value(forKey: maxNumberOfCardsKey) != nil {
            maxNumberOfCards = UserDefaults.standard.integer(forKey: maxNumberOfCardsKey)
        }
    }
    
}
