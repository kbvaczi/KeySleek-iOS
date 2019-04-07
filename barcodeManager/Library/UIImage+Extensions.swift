//
//  UIImage + Extensions.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/21/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import Accelerate

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
    
    /// Resizes image to fit within a new size while maintaining aspect ratio
    ///
    /// - Parameter fitSize: Size to fit image within
    /// - Returns: Resized image
    func resizeToFitSquare(ofDimension maxDimension: CGFloat) -> UIImage {
        var newSize: CGSize
        let aspectRatio = self.size.width / self.size.height
        if aspectRatio > 1.0 { // width > height
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else  { // height > width
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        return self.resize(to: newSize)
    }
    
    /// Resize image to given size using Accelerate Library
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    func resize(to newSize: CGSize) -> UIImage {
        var resultImage = self
        
        guard let cgImage = cgImage else { return resultImage }
        
        // create a source buffer
        var format = vImage_CGImageFormat(bitsPerComponent: numericCast(cgImage.bitsPerComponent),
                                          bitsPerPixel: numericCast(cgImage.bitsPerPixel),
                                          colorSpace: Unmanaged.passUnretained(cgImage.colorSpace!),
                                          bitmapInfo: cgImage.bitmapInfo,
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            sourceBuffer.data.deallocate()
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return resultImage }
        
        // create a destination buffer
        let destWidth = Int(newSize.width)
        let destHeight = Int(newSize.height)
        let bytesPerPixel = cgImage.bitsPerPixel
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return resultImage }
        
        // create a CGImage from vImage_Buffer
        let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return resultImage }
        
        // create a UIImage
        if let scaledImage = destCGImage.flatMap({ UIImage(cgImage: $0) }) {
            resultImage = scaledImage
        }
        
        return resultImage
    }
    
    
}
