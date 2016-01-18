//
//  UIFont+Extension.swift
//  Nibble
//
//  Created by Sachin on 10/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

extension UIFont {
	enum FontWeight {
		case Regular
		case Light
		case Medium
		case Semibold
	}
	
	class func appFontOfSize(size: CGFloat, weight: FontWeight) -> UIFont {
		var font = UIFont.systemFontOfSize(size)
		switch weight {
		case .Light: font = UIFont(name: "Graphik-Light", size: size)!
		case .Medium: font = UIFont(name: "Graphik-Medium", size: size)!
		case .Regular: font = UIFont(name: "Graphik-Regular", size: size)!
		default: break;
		}
		return font
	}
}