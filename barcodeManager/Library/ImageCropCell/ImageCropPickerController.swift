//
//  ImageCropPickerController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/20/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Eureka
import Foundation

/// Selector Controller used to pick an image
open class ImageCropPickerController: UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<UIImage>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        allowsEditing = false // allow editing false so we can use custom crop view
        delegate = self
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        (row as? ImageCropRow)?.imageToCrop = info[ (row as? ImageCropRow)?.useEditedImage ?? false ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        onDismissCallback?(self)
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        (row as? ImageCropRow)?.imageToCrop = nil
        onDismissCallback?(self)
    }
}
