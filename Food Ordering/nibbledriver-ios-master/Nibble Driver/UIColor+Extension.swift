//
//  UIColor+Extension.swift
//  Nibble
//
//  Created by Sachin on 10/13/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

extension UIColor {
	class func decimalColorWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
		return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
	}
	
	class func colorWithWhite(white: CGFloat) -> UIColor {
		return UIColor(red: white / 255.0, green: white / 255.0, blue: white / 255.0, alpha: 1.0)
	}
	
	class func appBackgroundColor() -> UIColor {
		return UIColor.colorWithWhite(244)
	}
	
	class func appSeparatorColor() -> UIColor {
		return UIColor.colorWithWhite(200)
	}
	
	class func appTintColor() -> UIColor {
		return UIColor.appTurquoiseColor()
	}
	
	class func appGreenColor() -> UIColor {
		return UIColor.decimalColorWithRed(68, green: 198, blue: 0, alpha: 1.0)
	}
	
	class func appTurquoiseColor() -> UIColor {
		return UIColor.decimalColorWithRed(45, green: 209, blue: 131, alpha: 1.0)
	}
	
	class func facebookBlueColor() -> UIColor {
		return UIColor.decimalColorWithRed(58, green: 79, blue: 162, alpha: 1.0)
	}
	
	class func imageWithColor(color: UIColor) -> UIImage {
		let rect:CGRect = CGRectMake(0, 0, 4, 4)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()!
		
		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	func lighterColor(percent : Double) -> UIColor {
		return colorWithBrightnessFactor(CGFloat(1 + percent));
	}
	
	func darkerColor(percent : Double) -> UIColor {
		return colorWithBrightnessFactor(CGFloat(1 - percent));
	}
	
	func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
		var hue = CGFloat(0)
		var saturation = CGFloat(0)
		var brightness = CGFloat(0)
		var alpha = CGFloat(0)
		
		if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
			return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
		} else {
			return self;
		}
	}
}