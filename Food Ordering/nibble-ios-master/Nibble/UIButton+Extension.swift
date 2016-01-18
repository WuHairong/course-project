//
//  UIButton+Extension.swift
//  Nibble Driver
//
//  Created by Sachin on 11/1/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

extension UIButton {
	class func roundedButtonWithColor(color: UIColor) -> UIButton {
		let button = UIButton()
		let normalImage = UIColor.imageWithColor(color).resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 1, 1))
		let highlightedImage = UIColor.imageWithColor(color.darkerColor(0.1)).resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 1, 1))
		button.setBackgroundImage(normalImage, forState: .Normal)
		button.setBackgroundImage(highlightedImage, forState: .Highlighted)
		button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		button.titleLabel?.font = UIFont.appFontOfSize(20.0, weight: .Regular)
		button.clipsToBounds = true
		button.layer.cornerRadius = 6.0
		return button
	}
	
	class func appSquaredButton() -> UIButton {
		let button = UIButton()
		let normalImage = UIColor.imageWithColor(UIColor.appTintColor()).resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 1, 1))
		let highlightedImage = UIColor.imageWithColor(UIColor.appTintColor().darkerColor(0.1)).resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 1, 1))
		let disabledImage = UIColor.imageWithColor(UIColor.grayColor()).resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 1, 1))
		button.setBackgroundImage(normalImage, forState: .Normal)
		button.setBackgroundImage(highlightedImage, forState: .Highlighted)
		button.setBackgroundImage(disabledImage, forState: .Disabled)
		button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		button.titleLabel?.font = UIFont.appFontOfSize(20.0, weight: .Regular)
		return button
	}
}
