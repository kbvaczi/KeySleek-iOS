//
//  UIImage + Extensions.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/21/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func roundCornersForAspectFit(radius: CGFloat) {
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect: CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

}

extension UIImage {
    
    func addCircleBackground(ofColor color: UIColor, ofSize requestedSize: CGSize? = nil) -> UIImage {
        
        let contextSize = requestedSize ?? CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(contextSize)

        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        context.setFillColor(color.cgColor)
        context.setAlpha(0.8)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: contextSize.width, height: contextSize.width))
        
        let imageAreaSize = CGRect(x: -(self.size.width - contextSize.width) / 2,
                                   y: -(self.size.height - contextSize.height) / 2,
                                   width: self.size.width, height: self.size.height)
        self.draw(in: imageAreaSize)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
}
