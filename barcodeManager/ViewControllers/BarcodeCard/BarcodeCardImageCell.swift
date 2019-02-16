//
//  BarcodeCardImageCell.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/3/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes
import Eureka

final class BarcodeCardImageCell: Cell<BarcodeCard>, CellType {
    
    @IBOutlet weak var barcodeImageView: UIImageView!
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
    }
    
    override func update() {
        super.update()
        guard let barcodeCard = row.value else { return }
        self.barcodeImageView.image = barcodeCard.barcodeImage
        self.barcodeImageView.contentMode = .scaleAspectFit
    }
    
}

final class BarcodeCardImageRow: Row<BarcodeCardImageCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<BarcodeCardImageCell>(nibName: "BarcodeCardImageCell")
    }
    
}
