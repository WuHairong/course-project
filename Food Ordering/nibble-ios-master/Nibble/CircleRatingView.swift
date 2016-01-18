//
//  CircleRatingView.swift
//  Nibble
//
//  Created by Sachin on 10/24/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class CircleRatingView: UIView {
	var rating: Float {
		didSet {
			label.text = NSString(format: "%.1f", rating) as String
			backgroundColor = color
		}
	}
	var color: UIColor {
		get {
			switch rating {
				case 0..<4: return UIColor.decimalColorWithRed(231, green: 69, blue: 0, alpha: 1)
				case 4..<8: return UIColor.decimalColorWithRed(245, green: 166, blue: 35, alpha: 1)
				default: return UIColor.decimalColorWithRed(68, green: 196, blue: 0, alpha: 1)
			}
		}
	}
	var label: UILabel
	
	init() {
		rating = 0.0
		label = UILabel()
		
		super.init(frame: CGRectZero)
		commonInit()
	}
	
	override init(frame: CGRect) {
		rating = 0.0
		label = UILabel()
		
		super.init(frame: frame)
		commonInit()
	}
	
	convenience init(rating: Float) {
		self.init(frame: CGRectZero)
		
		self.rating = rating
		commonInit()
	}
	
	func commonInit() {
		label.font = UIFont.appFontOfSize(16.0, weight: .Regular)
		label.textColor = UIColor.whiteColor()
		label.textAlignment = .Center
		addSubview(label)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.cornerRadius = frame.width / 2.0
		clipsToBounds = true
		
		label.frame = bounds
	}
}
