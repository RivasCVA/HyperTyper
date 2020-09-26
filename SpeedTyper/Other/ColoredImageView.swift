//
//  ColoredImageView.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 8/15/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit

class ColoredImageView: UIImageView {
    
    //User can set the Image Color for select view
    @IBInspectable
    var imageColor: UIColor! {
        didSet {
            image = image?.maskWithColor(color: imageColor)
        }
    }

}

//Extension to change UIImage color programmatically
extension UIImage {
    
    public func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
}
