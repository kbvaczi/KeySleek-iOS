//
//  BarcodeImageCell.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/3/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import FontAwesome_swift
import Eureka

final class BarcodeImageCell: Cell<UIImage>, CellType {
    
    @IBOutlet weak var barcodeImageView: UIImageView!
        
    override func update() {
        super.update()
        self.selectionStyle = .none
        self.barcodeImageView.contentMode = .scaleAspectFit
        guard let barcodeImage = row.value else {
            let cameraImage = UIImage.fontAwesomeIcon(name: .camera,
                                                      style: .solid,
                                                      textColor: .lightGray,
                                                      size: CGSize(width: 44, height: 44))
            self.barcodeImageView.image = cameraImage
            return
        }
        self.barcodeImageView.image = barcodeImage
    }
    
}

final class BarcodeImageRow: Row<BarcodeImageCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<BarcodeImageCell>(nibName: "BarcodeImageCell")
    }
    
}
