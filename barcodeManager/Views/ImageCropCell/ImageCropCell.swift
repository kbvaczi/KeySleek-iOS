//
//  ImageCropCell.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/17/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Eureka

public final class ImageCropCell: PushSelectorCell<UIImage> {
    public override func setup() {
        super.setup()
        
        accessoryType = .none
        editingAccessoryView = .none
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        accessoryView = imageView
        editingAccessoryView = imageView
    }
    
    public override func update() {
        super.update()
        
        selectionStyle = row.isDisabled ? .none : .default

        (accessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
        (editingAccessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
    }
}
