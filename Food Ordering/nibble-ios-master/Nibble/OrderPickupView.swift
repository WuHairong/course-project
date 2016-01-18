//
//  OrderPickupView.swift
//  Nibble
//
//  Created by Sachin on 11/20/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class OrderPickupView: UIView {
	var leftLabel: UILabel
	var rightLabel: UILabel
	
	override init(frame: CGRect) {
		leftLabel = UILabel()
		rightLabel = UILabel()
		
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func commonInit() {		
		leftLabel.font = UIFont.appFontOfSize(15.0, weight: .Regular)
		leftLabel.textColor = UIColor.darkGrayColor()
		addSubview(leftLabel)
		
		rightLabel.font = UIFont.appFontOfSize(15.0, weight: .Regular)
		rightLabel.textColor = UIColor.darkGrayColor()
		rightLabel.textAlignment = .Right
		addSubview(rightLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		leftLabel.frame = CGRectMake(10.0, 0.0, 100.0, 20.0)
		rightLabel.frame = CGRectMake(frame.width - 100.0 - 10.0, 0.0, 100.0, 20.0)
	}
}
