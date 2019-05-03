//
//  BarcodeCardTableViewCell.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/22/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class BarcodeCardTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var cardPhotoImageView: UIImageView!
    @IBOutlet weak var cardPhotoImageHeightConstraint: NSLayoutConstraint!
    
    func animateIn() {
        cardPhotoImageView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.cardPhotoImageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        })
    }
    
}
