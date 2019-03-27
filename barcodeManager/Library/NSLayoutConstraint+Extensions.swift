//
//  NSLayoutConstraint+Extensions.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 3/24/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
 
    func copyWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint? {

        guard let firstItem = self.firstItem else { return nil }
        
        return NSLayoutConstraint(item: firstItem,
                                  attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem,
                                  attribute: self.secondAttribute,
                                  multiplier: multiplier,
                                  constant: self.constant)
        
    }
    
}
