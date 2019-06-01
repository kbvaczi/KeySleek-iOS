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
    
    /// True if app is unlocked, false if not
    var isAppUnlocked: Bool = false {
        didSet {
            UserDefaults.standard.set(isAppUnlocked, forKey: isAppUnlockedKey)
            if isAppUnlocked {
                maxNumberOfCards = 100
            } else {
                maxNumberOfCards = 5
            }
        }
    }
    private let isAppUnlockedKey = "isAppUnlocked"
    
    /// When set to true, allows manually editing barcodes, default is false
    var toAllowBarcodeEditing: Bool = false {
        didSet {
            UserDefaults.standard.set(toAllowBarcodeEditing, forKey: toAllowBarcodeEditingKey)
        }
    }
    private let toAllowBarcodeEditingKey = "toAllowBarcodeEditing"
    
    /// Maximum number of cards that can be created, default is 5
    var maxNumberOfCards: Int = 5 {
        didSet {
            UserDefaults.standard.set(maxNumberOfCards, forKey: maxNumberOfCardsKey)
        }
    }
    
    private let maxNumberOfCardsKey = "maxNumberOfCards"
    
    /// Disallow external instances of this class
    fileprivate init() {
        if UserDefaults.standard.value(forKey: isAppUnlockedKey) != nil {
            isAppUnlocked = UserDefaults.standard.bool(forKey: isAppUnlockedKey)
        }
        if UserDefaults.standard.value(forKey: toAllowBarcodeEditingKey) != nil {
            toAllowBarcodeEditing = UserDefaults.standard.bool(forKey: toAllowBarcodeEditingKey)
        }
        if UserDefaults.standard.value(forKey: maxNumberOfCardsKey) != nil {
            maxNumberOfCards = UserDefaults.standard.integer(forKey: maxNumberOfCardsKey)
        }
    }
    
}
