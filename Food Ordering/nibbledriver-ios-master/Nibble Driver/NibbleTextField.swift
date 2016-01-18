//
//  NibbleTextField.swift
//  Nibble
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class NibbleTextField: UITextField {
	let xInset = CGFloat(10)
	let yInset = CGFloat(0)
	
	init() {
		super.init(frame: CGRectZero)
		backgroundColor = UIColor.appBackgroundColor()
		font = UIFont.appFontOfSize(18.0, weight: .Regular)
		
		clipsToBounds = true
		layer.cornerRadius = 6.0
		layer.borderWidth = 0.5
		layer.borderColor = UIColor.lightGrayColor().CGColor
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, xInset, yInset)
	}
	
	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, xInset, yInset)
	}
	
	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, xInset, yInset)
	}
}
