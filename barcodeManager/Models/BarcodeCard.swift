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
    
    var title: String?
    var code: String
    var codeTypeString: String
    var codeType: BarcodeCards.barcodeType? {
        return BarcodeCards.barcodeType(rawValue: codeTypeString)
    }
    var barcodeImage: UIImage? {
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.white
        gen.strokeColor = UIColor.black
        
        print ("generating image with barcode: " + self.code)
        if let image = gen.generateCode(self.code,
                                        machineReadableCodeObjectType: self.codeTypeString) {
            
            if self.codeType == .QR || self.codeType == .Aztec {
                let scaledImage = RSAbstractCodeGenerator.resizeImage(image, targetSize: CGSize(width: 250, height: 250), contentMode: .scaleAspectFit)
                return scaledImage
            } else {
                let scaledImage = RSAbstractCodeGenerator.resizeImage(image, targetSize: CGSize(width: 250, height: 100), contentMode: .scaleAspectFit)
                return scaledImage
            }
        }
        return nil
    }
    
    static func == (lhs: BarcodeCard, rhs: BarcodeCard) -> Bool  {
        if  lhs.code == rhs.code,
            lhs.title == rhs.title,
            lhs.codeTypeString == rhs.codeTypeString {
            return true
        }
        return false
    }
    
    init(title: String?, code: String, codeType: BarcodeCards.barcodeType) {
        self.title = title
        self.code = code
        self.codeTypeString = codeType.rawValue
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
