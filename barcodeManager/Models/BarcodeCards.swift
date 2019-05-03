//
//  BarcodeCards.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 4/7/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Foundation
import AVFoundation
import Disk

typealias UID = String

class BarcodeCards {
    
    static let instance = BarcodeCards()
    
    private let indexFileName: String = "barcodeCards.json"
    private var cardsIndex: [UID]? = nil
    
    enum barcodeType: String, CustomStringConvertible, CaseIterable {
        case Code39 = "org.iso.Code39"
        case Code39Mod43 = "org.iso.Code39Mod43"
        case Code93 = "com.intermec.Code93"
        case Code128 = "org.iso.Code128"
        case UPCE = "org.gs1.UPC-E"
        case EAN8 = "org.gs1.EAN-8"
        case EAN13 = "org.gs1.EAN-13"
        case ITF14 = "org.gs1.ITF14"
        case Interleaved2of5 = "org.ansi.Interleaved2of5"
        case DataMatrix = "org.iso.DataMatrix"
        case PDF417 = "org.iso.PDF417"
        case QR = "org.iso.QRCode"
        case Aztec = "org.iso.Aztec"
        
        var description: String {
            switch self {
            case .Code39:
                return "Code 39"
            case .Code39Mod43:
                return "Code 39 (Mod 43)"
            case .Code93:
                return "Code 93"
            case .Code128:
                return "Code 128"
            case .UPCE:
                return "UPCE"
            case .EAN8:
                return "EAN-8"
            case .EAN13:
                return "EAN-13"
            case .ITF14:
                return "ITF-14"
            case .Interleaved2of5:
                return "ITF (Interleaved 2 of 5)"
            case .DataMatrix:
                return "Data Matrix"
            case .PDF417:
                return "PDF417"
            case .QR:
                return "QR Code"
            case .Aztec:
                return "Aztec"
            }
        }
        
        var metaDataObjectType: AVMetadataObject.ObjectType {
            return AVMetadataObject.ObjectType.init(rawValue: self.rawValue)
        }
    }
    
    /// Prevent creation of multiple instances of this class
    private init() {}
    
}

// MARK: - Private Functions
private extension BarcodeCards {
    
    
    private func barcodeCardFileNameFor(uid: UID) -> String {
        return "barcode_\(uid).json"
    }
    
    /// Saves cardsIndex to file
    ///
    /// - Parameter callBack: performed after saving, contains true if saved, false if not
    private func saveCardsIndex(callBack: @escaping (Bool) -> Void) {
        guard self.cardsIndex != nil else {
            print("Error: trying to save cards index prior to loading")
            callBack(false)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.save(self.cardsIndex, to: .documents, as: self.indexFileName)
                callBack(true)
            } catch {
                print("error saving cards index from file")
                callBack(false)
            }
        }
    }
    
    /// Synchronously loads a single BarcodeCard from an individual file (does not affect cards index)
    ///
    /// - Parameter uid: UID for card to load
    /// - Returns: BarcodeCard with given UID, if it exists
    private func loadBarcodeCardWith(uid: UID) -> BarcodeCard? {
        let fileName = barcodeCardFileNameFor(uid: uid)
        do {
            let card = try Disk.retrieve(fileName, from: .documents, as: BarcodeCard.self)
            return card
        } catch {
            print("error loading barcode \(uid) from file")
            return nil
        }
    }
    
    
    /// Asynchronously loads a single BarcodeCard from an individual file (does not affect cards index)
    ///
    /// - Parameters:
    ///   - uid: uid of BarcodeCard
    ///   - callBack: Executed after loading, contains BarcodeCard object if loaded
    private func loadBarcodeCardWith(uid: UID, callBack: @escaping (BarcodeCard?) -> () ) {
        DispatchQueue.global(qos: .userInitiated).async {
            callBack(self.loadBarcodeCardWith(uid: uid))
        }
    }
    
    /// Asynchronously saves a single BarcodeCard to file (does not affect cards index)
    ///
    /// - Parameters:
    ///   - barcodeCard: Object to save to file
    ///   - callBack: Performed after saving, true if successful, false if unsuccessful
    private func saveBarcodeCard(_ barcodeCard: BarcodeCard, callBack: @escaping (Bool) -> () ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileName = self.barcodeCardFileNameFor(uid: barcodeCard.uid)
            do {
                try Disk.save(barcodeCard, to: .documents, as: fileName)
                barcodeCard.savePhotoToFile(callBack: { didSave in
                    callBack(didSave)
                })
            } catch {
                print("error saving barcode \(barcodeCard.uid) to file")
                callBack(false)
            }
        }
    }
    
    /// Asyncrhonously deletes a BarcodeCard object from file (does not affect cards index)
    ///
    /// - Parameters:
    ///   - uid: UID of BarcodeCard to delete
    ///   - callBack: true if deleted, false if problem with deletion
    private func deleteBarcodeCardWith(uid: UID, callBack: @escaping (Bool) -> () ) {
        let fileName = barcodeCardFileNameFor(uid: uid)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.remove(fileName, from: .documents)
                callBack(true)
            } catch {
                print("error deleting barcode \(uid) from file")
                callBack(false)
            }
        }
    }
    
    /// Loads an array of BarcodeCard objects in order based on an array of UIDs given, invalid UIDs are ignored
    ///
    /// - Parameters:
    ///   - uids: Array of UIDs to load
    ///   - callBack: Performed after loading, includes loaded BarcodeCard objects array
    private func loadBarcodeCardsWith(uids: [UID], callBack: @escaping ([BarcodeCard]) -> ()) {
        var loadedCards = [BarcodeCard?]()
        let dpGroup = DispatchGroup()
        // Asynchronous tasks may not complete in order, let's assign a nil placeholder then
        // insert each item into the correct index
        for (index, uid) in uids.enumerated() {
            loadedCards.append(nil)
            dpGroup.enter()
            loadBarcodeCardWith(uid: uid, callBack: { returnedValue in
                if let barcodeCard = returnedValue {
                    loadedCards.insert(barcodeCard, at: index)
                }
                dpGroup.leave()
            })
        }
        // All cards have been loaded, let's remove any placeholders for cards that were not loaded
        dpGroup.notify(qos: .userInitiated, flags: .enforceQoS, queue: .global(), execute: {
            var orderedCards = [BarcodeCard]()
            for possibleCard in loadedCards {
                if let card = possibleCard {
                    orderedCards.append(card)
                }
            }
        })
    }
    
}

// MARK: - Public API
extension BarcodeCards {
    

    /// Returns the number of BarcodeCard objects currently loaded
    func numberOfSavedCards() -> Int {
        return cardsIndex?.count ?? 0
    }
    
    
    /// Loads an index of UIDs from file for saved cards and saves into private variable cardsIndex
    ///
    /// - Parameter callBack: performed after loading, contains true if loaded, false if not
    @discardableResult func loadCardsIndex() -> Bool {
        do {
            self.cardsIndex = try Disk.retrieve(self.indexFileName, from: .documents,
                                                as: [UID].self)
            return true
        } catch {
            print("error loading cards index from file, creating new index")
            self.cardsIndex = []
            return false
        }
    }
    
    /// Returns index of BarcodeCard object in the cards index
    ///
    /// - Parameter barcodeCard: barcodeCard
    /// - Returns: index in cards index
    func indexOf(_ barcodeCard: BarcodeCard) -> Int? {
        return self.cardsIndex?.index(of: barcodeCard.uid)
    }
    
    /// Synchronously loads a BarcodeCard from list of saved BarcodeCards
    func loadCard(withIndex index: Int) -> BarcodeCard? {
        guard let loadedIndex = self.cardsIndex else {
            if loadCardsIndex() {
                return loadCard(withIndex: index)
            } else {
                return nil
            }
        }
        guard index >= 0, index < loadedIndex.count else {
            print("Error: attempted to load BarcodeCard index out of range")
            return nil
        }
        let uid = loadedIndex[index]
        return loadBarcodeCardWith(uid: uid)
    }
    
    /// Remove BarcodeCard from a given index and delete it from file
    ///
    /// - Parameters:
    ///   - index: index of BarcodeCard to delete
    ///   - callBack: true if removed, false otherwise
    func removeCard(withIndex index: Int, callBack: ((Bool) -> Void)? = nil ) {
        guard index >= 0, let cardsIndex = self.cardsIndex, index < cardsIndex.count else {
            print("Error: attempted to remove BarcodeCard index out of range")
            callBack?(false)
            return
        }
        let uid = self.cardsIndex![index]
        self.cardsIndex?.remove(at: index)
        saveCardsIndex(callBack: { didSave in
            if didSave {
                self.deleteBarcodeCardWith(uid: uid, callBack: { didDelete in
                    callBack?(true)
                })
            } else {
                callBack?(false)
            }
        })
    }
    
    /// Remove BarcodeCard and delete it from file
    ///
    /// - Parameter cardToRemove: BarcodeCard to remove
    /// - Returns: true if removed, otherwise false
    func removeCardWith(uid: UID, callBack: ((Bool) -> Void)? = nil ) {
        let barcodeCardfileName = barcodeCardFileNameFor(uid: uid)
        guard let cardsIndex = self.cardsIndex, cardsIndex.count > 0 else {
            callBack?(false)
            print("Error: trying to remove card prior to loading index")
            return
        }
        if let index = cardsIndex.index(of: uid), Disk.exists(barcodeCardfileName, in: .documents) {
            self.cardsIndex?.remove(at: index)
            saveCardsIndex(callBack: { didSave in
                if didSave {
                    self.deleteBarcodeCardWith(uid: uid, callBack: { didDelete in
                        callBack?(true)
                    })
                } else {
                    callBack?(false)
                }
            })
        } else {
            callBack?(false)
        }
    }
    
    /// Adds new BarcodeCard object to saved BarcodeCards
    ///
    /// - Parameters:
    ///   - cardToAdd: BarcodeCard object to add
    ///   - callBack: Performed after save attempt: contains True if saved, false otherwise
    func add(_ cardToAdd: BarcodeCard, callBack: ((Bool) -> Void)? = nil ) {
        cardsIndex?.append(cardToAdd.uid)
        saveCardsIndex(callBack: { didSave in
            if didSave {
                self.saveBarcodeCard(cardToAdd, callBack: { didSave in
                    callBack?(didSave)
                    if !didSave {
                        print("Error: unable to add new BarcodeCard, reverting index")
                        self.cardsIndex?.removeLast()
                    }
                })
            } else { // Revert
                callBack?(false)
                self.cardsIndex?.removeLast()
            }
        })
    }
    
    /// Update a saved BarcodeCard object
    ///
    /// - Parameters:
    ///   - updatedCard: Updated card to save
    ///   - callBack: Performed after save attempt: contains True if saved, false otherwise
    func update(_ updatedCard: BarcodeCard, callBack: ((Bool) -> Void)? = nil) {
        saveBarcodeCard(updatedCard, callBack: { didSave in
            callBack?(didSave)
        })
    }
    
    /// Moves a BarcodeCard from one position to another
    ///
    /// - Parameters:
    ///   - fromPosition: current position of card to move
    ///   - toPosition: position to move card to
    ///   - callBack: Performed after save attempt - contains true if saved, false otherwise
    func moveCard(fromPosition: Int, toPosition: Int, callBack: ((Bool) -> Void)? = nil) {
        guard   let loadedIndex = self.cardsIndex, fromPosition >= 0, toPosition >= 0,
                fromPosition < loadedIndex.count, toPosition < loadedIndex.count else {
            print("Error: tried to move card out of index range")
            callBack?(false)
            return
        }
        self.cardsIndex!.insert(self.cardsIndex!.remove(at: fromPosition), at: toPosition)
        saveCardsIndex(callBack: { didSave in
            callBack?(didSave)
        })
    }
    
}


