//
//  UIColorExtension.swift
//  CastRemote
//
//  Created by Coty Embry on 12/8/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

import Foundation


//This helps for color gradients
/*
http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios/24263296#24263296

#ffffff are actually 3 color components in hexadecimal notation - red ff, green ff and blue ff. You can write hexadecimal notation in Swift using 0x prefix, e.g 0xFF

To simplify the conversion, let's create an initializer that takes integer (0 - 255) values:

Usage:
var color = UIColor(red: 0xFF, green: 0xFF, blue: 0xFF)
var color2 = UIColor(netHex:0xFFFFFF)
*/
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}