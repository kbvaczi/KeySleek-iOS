//
//  BarcodeCard.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import Disk

struct BarcodeCard: Codable, Equatable {
    
    var uid: String
    var title: String?
    var notes: String?
    var account: String?
    var code: String?
    var codeTypeString: String?
    
    private var _photoSize: CGSize?
    private var _photoWrapped: imageWrapper = imageWrapper()
    
    init(title: String? = nil, notes: String? = nil,
         code: String? = nil, account: String? = nil,
         codeType: BarcodeCards.barcodeType? = nil) {
        
        self.uid = UUID().uuidString
        self.title = title
        self.notes = notes
        self.account = account
        self.code = code
        self.codeTypeString = codeType?.rawValue
    }
    
}


// MARK: - Private functions
private extension BarcodeCard {
    
    /// Generates a consisten file name based on uid
    private var photoFileName: String { return "\(self.uid)_photo.png" }
    
}

// MARK: - Public API
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
            lhs.account == rhs.account,
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
        gen.fillColor = UIColor.clear
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
    
    /// Synchronously accesses photo, does not save photo to file if assigned a value
    var photo: UIImage? {
        get {
            if let photoAlreadyLoaded = _photoWrapped.image { return photoAlreadyLoaded }
            guard Disk.exists(self.photoFileName, in: .documents) else { return nil }
            do {
                let image = try Disk.retrieve(self.photoFileName, from: .documents, as: UIImage.self)
                _photoWrapped.image = image
                return image
            } catch {
                print("error loading photo for BarcodeCard UID \(self.uid) from file")
                return nil
            }
        }
        set {
            if let newPhoto = newValue?.resizeToFitSquare(ofDimension: 1000) {
                _photoSize = newPhoto.size
                _photoWrapped.image = newPhoto
            }
        }
    }
    
    /// Asyncronhously loads photo
    ///
    /// - Parameter callBack: performed after photo loaded, contains photo if exists
    func loadPhotoFromFile(callBack: ((UIImage?) -> Void)? = nil) {
        if let photo = _photoWrapped.image { callBack?(photo); return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let image = try Disk.retrieve(self.photoFileName, from: .documents, as: UIImage.self)
                self._photoWrapped.image = image
                callBack?(image)
            } catch {
                print("error loading photo for BarcodeCard UID \(self.uid) from file")
                callBack?(nil)
            }
        }
    }
    
    /// Asyncronously saves photo
    ///
    /// - Parameters:
    ///   - image: image to save
    ///   - callBack: performed after saving, contains true if successful, false otherwise
    func savePhotoToFile(callBack:  ((Bool) -> Void)? = nil ) {
        guard let imageData = photo?.pngData() else { callBack?(true); return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.save(imageData, to: .documents, as: self.photoFileName)
                callBack?(true)
            } catch {
                print("error saving photo for BarcodeCard UID \(self.uid) to file")
                callBack?(false)
            }
        }
    }
    
    var photoSize: CGSize? {
        get {
            if let setSize = self._photoSize {
                return setSize
            }
            return nil
        }
    }

}


/// Provides a transient wrapper for UIImage that conforms to Codable, but does not encode/decode any data
class imageWrapper: Codable {
    
    var image: UIImage? = nil
    
    init() {}
    
    required init(from decoder: Decoder) throws { }
    
    func encode(to encoder: Encoder) throws { }
    
}
