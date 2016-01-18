//
//  RestaurantTimeButton.swift
//  Nibble
//
//  Created by Sachin on 11/2/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class RestaurantTimeButton: UICollectionViewCell {
	class var sharedTimeFormatter: NSDateFormatter {
		struct Static {
			static var onceToken: dispatch_once_t = 0
			static var instance: NSDateFormatter? = nil
		}
		dispatch_once(&Static.onceToken) {
			Static.instance = NSDateFormatter()
			Static.instance?.dateFormat = "h:mm a"
			Static.instance?.timeZone = NSTimeZone(name: "PST")
		}
		return Static.instance!
	}
	
	var date: NSDate {
		didSet {
			let timeString = RestaurantTimeButton.sharedTimeFormatter.stringFromDate(date)
			button.setTitle(timeString, forState: .Normal)
		}
	}
	var button: UIButton
	
	override init(frame: CGRect) {
		date = NSDate()
		button = UIButton()
		
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		button.backgroundColor = UIColor.appTintColor()
		button.titleLabel?.font = UIFont.appFontOfSize(18.0, weight: .Regular)
		button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		contentView.addSubview(button)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -
	override func prepareForReuse() {
		super.prepareForReuse()
		button.setTitle(nil, forState: .Normal)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		button.frame = contentView.frame
		button.layer.cornerRadius = 18.0
	}
}
