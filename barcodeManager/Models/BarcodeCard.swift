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
    var code: String?
    var codeTypeString: String?
    
    private var photoData: Data?
    private var _photoSize: CGSize?
    
    static func == (lhs: BarcodeCard, rhs: BarcodeCard) -> Bool  {
        if  lhs.code == rhs.code,
            lhs.title == rhs.title,
            lhs.codeTypeString == rhs.codeTypeString {
            return true
        }
        return false
    }
    
    init(title: String? = nil, code: String? = nil, codeType: BarcodeCards.barcodeType? = nil) {
        self.uid = UUID().uuidString
        self.title = title
        self.code = code
        self.codeTypeString = codeType?.rawValue
        
    }
    
}

extension BarcodeCard {
    
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
    
    private let saveFileName: String = "barcodes.json"
    
    private var cards: [BarcodeCard]
    
    private init() {
        cards = [BarcodeCard]()
        loadFromFile()
    }
    
    func list() -> [BarcodeCard] {
        return cards
    }
    
    /// remove
    ///
    /// - Parameter cardToRemove: BarcodeCard to remove
    /// - Returns: true if removed, otherwise false
    @discardableResult func remove(_ cardToRemove: BarcodeCard) -> Bool {
        for (index, card) in self.cards.enumerated() {
            if card == cardToRemove {
                cards.remove(at: index)
                return saveToFile()
            }
        }
        return false
    }
    
    /// add
    ///
    /// - Parameter cardToAdd: Adds a BarcodeCard to BarcodeCards list
    /// - Returns: true if added, otherwise false
    @discardableResult func add(_ cardToAdd: BarcodeCard) -> Bool {
        cards.append(cardToAdd)
        if saveToFile() {
            return true
        } else {
            cards.removeLast()
            return false
        }
    }
    
    /// update
    ///
    /// - Parameter cardToAdd: Adds a BarcodeCard to BarcodeCards list
    /// - Returns: true if added, otherwise false
    @discardableResult func update(_ cardToUpdate: BarcodeCard, with newCard: BarcodeCard) -> Bool {
        for (index, card) in self.cards.enumerated() {
            if card == cardToUpdate {
                cards[index] = newCard
                return saveToFile()
            }
        }
        return false
    }
    
    /// move card from one position to another
    ///
    /// - Parameters:
    ///   - fromPosition: position to move card from
    ///   - toPosition: position to move card to
    /// - Returns: true if saved, false otherwise
    @discardableResult func moveCard(fromPosition: Int, toPosition: Int) -> Bool {
        let cardToMove = cards.remove(at: fromPosition)
        cards.insert(cardToMove, at: toPosition)
        return saveToFile()
    }
    
    /// loadFromFile
    ///
    /// - Returns: loads barcodecards from file
    @discardableResult private func loadFromFile() -> Bool {
        do {
            try self.cards = Disk.retrieve(saveFileName, from: .documents, as: [BarcodeCard].self)
            return true
        } catch {
            print("error loading barcodes from file")
            return false
        }
    }
    
    /// saveToFile
    ///
    /// - Returns: saves barcode cards to file
    @discardableResult private func saveToFile() -> Bool {
        do {
            try Disk.save(cards, to: .documents, as: saveFileName)
            return true
        } catch {
            print("error saving barcodes to file")
            return false
        }
    }
}


