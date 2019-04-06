//
//  BarcodeCard.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import Disk
import RSBarcodes

struct BarcodeCard: Codable, Equatable {
    
    var uid: String
    var title: String?
    var notes: String?
    var code: String?
    var codeTypeString: String?
    
    private var photoData: Data?
    private var _photoSize: CGSize?
    
    init(title: String? = nil, notes: String? = nil,
         code: String? = nil, codeType: BarcodeCards.barcodeType? = nil) {
        
        self.uid = UUID().uuidString
        self.title = title
        self.notes = notes
        self.code = code
        self.codeTypeString = codeType?.rawValue
    }
    
}

extension BarcodeCard {
    
    /// Tests whether two BarcodeCard objects have the same UID
    ///
    /// - Returns: True if UIDs match, False otherwise
    static func ~= (lhs: BarcodeCard, rhs: BarcodeCard) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    /// Tests whether two BarcodeCard objects are exactly the same (does not compare Photo)
    ///
    /// - Returns: True if equal, False otherwise
    static func == (lhs: BarcodeCard, rhs: BarcodeCard) -> Bool  {
        if  lhs.uid == rhs.uid,
            lhs.code == rhs.code,
            lhs.title == rhs.title,
            lhs.notes == rhs.notes,
            lhs.codeTypeString == rhs.codeTypeString {
            return true
        }
        return false
    }
    
    var codeType: BarcodeCards.barcodeType? {
        guard let codeTypeString = self.codeTypeString else { return nil }
        return BarcodeCards.barcodeType(rawValue: codeTypeString)
    }
    
    var barcodeImage: UIImage? {
        
        guard   let codeTypeString = self.codeTypeString,
                let code = self.code else { return nil }
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.white
        gen.strokeColor = UIColor.black
    
        if let image = gen.generateCode(code, machineReadableCodeObjectType: codeTypeString) {
            
            if self.codeType == .QR || self.codeType == .Aztec {
                let scaledImage = RSAbstractCodeGenerator.resizeImage(image, targetSize: CGSize(width: 250, height: 250), contentMode: .scaleToFill)
                return scaledImage
            } else {
                let scaledImage = RSAbstractCodeGenerator.resizeImage(image, targetSize: CGSize(width: 250, height: 100), contentMode: .scaleToFill)
                return scaledImage
            }
        }
        return nil
    }
    
    private var photoPath: String { return "\(self.uid).png" }
    
    var photo: UIImage? {
        get {
            guard let imageData = self.photoData else { return nil }
            return UIImage(data: imageData)
        }
        set {
            guard let imageData = newValue?.pngData() else { return }
            self.photoData = imageData
            self._photoSize = newValue?.size
        }
    }
    
    var photoSize: CGSize? {
        get {
            if let setSize = self._photoSize {
                return setSize
            }
            if let newSize = self.photo?.size {
                return newSize
            }
            return nil
        }
    }

}

class BarcodeCards {
    
    static let instance = BarcodeCards()
    
    private let saveFileName: String = "barcodes.json"
    private var cards: [BarcodeCard]
    
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
    
    private init() {
        cards = [BarcodeCard]()
    }
    
}

// MARK: - API
extension BarcodeCards {
    
    /// Lists existing BarcodeCards
    ///
    /// - Returns: BarcodeCards that are currently saved
    @discardableResult func list() -> [BarcodeCard] {
        return cards
    }
    
    /// remove
    ///
    /// - Parameter cardToRemove: BarcodeCard to remove
    /// - Returns: true if removed, otherwise false
    func remove(_ cardToRemove: BarcodeCard, callBack: ((Bool) -> Void)? = nil ) {
        for (index, card) in self.cards.enumerated() {
            if card ~= cardToRemove {
                let removedCard = cards[index]
                cards.remove(at: index)
                saveToFile() { didSave in
                    if didSave {
                        callBack?(true)
                    } else { // Revert
                        self.cards.insert(removedCard, at: index)
                        callBack?(false)
                    }
                }
            }
        }
    }
    
    /// Adds new BarcodeCard object to saved BarcodeCards
    ///
    /// - Parameters:
    ///   - cardToAdd: BarcodeCard object to add
    ///   - callBack: Performed after save attempt: contains True if saved, false otherwise
    func add(_ cardToAdd: BarcodeCard, callBack: ((Bool) -> Void)? = nil ) {
        cards.append(cardToAdd)
        saveToFile() { didSave in
            if didSave {
                callBack?(true)
            } else { // Revert
                self.cards.removeLast()
                callBack?(false)
            }
        }
    }
    
    /// Update a saved BarcodeCard object
    ///
    /// - Parameters:
    ///   - updatedCard: Updated card to save
    ///   - callBack: Performed after save attempt: contains True if saved, false otherwise
    func update(_ updatedCard: BarcodeCard, callBack: ((Bool) -> Void)? = nil) {
        for (index, card) in self.cards.enumerated() {
            if card ~= updatedCard {
                let oldCard = cards[index]
                cards[index] = updatedCard
                saveToFile() { didSave in
                    if didSave {
                        callBack?(true)
                    } else { // Revert
                        self.cards[index] = oldCard
                        callBack?(false)
                    }
                }
            }
        }
    }
    
    /// Moves a BarcodeCard from one position to another
    ///
    /// - Parameters:
    ///   - fromPosition: current position of card to move
    ///   - toPosition: position to move card to
    ///   - callBack: Performed after save attempt - contains true if saved, false otherwise
    func moveCard(fromPosition: Int, toPosition: Int, save: Bool? = nil,
                  callBack: ((Bool) -> Void)? = nil) {
        cards.insert(cards.remove(at: fromPosition), at: toPosition)
        guard let toPerformSave = save, toPerformSave else { return }
        saveToFile() { didSave in
            if didSave {
                callBack?(true)
            } else { // Revert
                self.cards.insert(self.cards.remove(at: toPosition), at: fromPosition)
                callBack?(false)
            }
        }
    }
    
    /// Loads saved BarcodeCard objects from file
    ///
    /// - Parameter callBack: Performed after loading - contains true if loaded, false otherwise
    func loadFromFile(callBack: ((Bool) -> ())? = nil ) {
        // Load from main queue to allow in TableView.updateView()
        let dispatchQueue = DispatchQueue(label: "Loading Barcodes", qos: .background)
        dispatchQueue.async {
            do {
                try self.cards = Disk.retrieve(self.saveFileName,
                                               from: .documents, as: [BarcodeCard].self)
                print("loading barcodes from file")
                DispatchQueue.main.async { callBack?(true) }
            } catch {
                print("error loading barcodes from file")
                DispatchQueue.main.async { callBack?(false) }
            }
        }
    }
    
    /// Save BarcodeCard objects to file
    ///
    /// - Parameter callBack: Performed after save attempt - contains true if saved, false otherwise
    func saveToFile(callBack: ((Bool) -> ())? = nil ) {
        let dispatchQueue = DispatchQueue(label: "Saving Barcodes", qos: .background)
        dispatchQueue.async {
            do {
                try Disk.save(self.cards, to: .documents, as: self.saveFileName)
                DispatchQueue.main.async { callBack?(true) }
            } catch {
                print("error saving barcodes to file")
                DispatchQueue.main.async { callBack?(false) }
            }
        }
    }
    
}


