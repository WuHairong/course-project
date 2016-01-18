//
//  OrderConfirmedView.swift
//  Nibble
//
//  Created by Sachin on 11/20/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class OrderConfirmedView: UIView {
	var imageView: UIImageView
	var titleLabel: UILabel
	var subtitleLabel: UILabel
	
	override init(frame: CGRect) {
		imageView = UIImageView()
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		imageView.contentMode = .Center
		imageView.image = UIImage(named: "confirmed_checkmark")
		addSubview(imageView)
		
		titleLabel.font = UIFont.appFontOfSize(22.0, weight: .Regular)
		titleLabel.text = "Your order has been placed."
		titleLabel.textColor = UIColor.blackColor()
		titleLabel.textAlignment = .Center
		addSubview(titleLabel)
		
		subtitleLabel.font = UIFont.appFontOfSize(18.0, weight: .Regular)
		subtitleLabel.textColor = UIColor.lightGrayColor()
		subtitleLabel.numberOfLines = 0
		subtitleLabel.lineBreakMode = .ByWordWrapping
		
		// Better line spacing
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .Center
		paragraphStyle.lineSpacing = 7
		
		let attributedString = NSMutableAttributedString(string: "You'll be notified of the pickup location once a driver is assigned. Thanks for ordering with Nibble.")
		attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
		subtitleLabel.attributedText = attributedString
		
		addSubview(subtitleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRectMake(0, 0, frame.width, 94.0)
		titleLabel.frame = CGRectMake(0, imageView.frame.maxY + 40, frame.width, 40)
		subtitleLabel.frame = CGRectMake(0, titleLabel.frame.maxY + 10, frame.width, 80)
	}
}
