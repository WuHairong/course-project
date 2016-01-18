//
//  DashboardStatusView.swift
//  Nibble Driver
//
//  Created by Sachin on 11/22/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

protocol DashboardStatusViewDelegate {
	func dashboardStatusViewTapped(statusView: DashboardStatusView)
}

class DashboardStatusView: UICollectionReusableView {
	var delegate: DashboardStatusViewDelegate?
	var post: Post? {
		didSet {
			if post!.active {
				backgroundColor = UIColor.appTintColor()
				titleLabel.text = "You're online."
				subtitleLabel.text = "tap to view details".uppercaseString
				
				let formatter = NSDateFormatter()
				formatter.dateFormat = "h:mm a"
				formatter.timeZone = NSTimeZone(name: "PST")
				let timeString = formatter.stringFromDate(post!.deliveryTime)
				
				let detailsString = "Delivering from: \(post!.restaurant.name)\nDelivering to: \(post!.deliveryLocation.name)\nDelivering at: \(timeString)"
				
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.lineSpacing = 10
				let attributes = [NSFontAttributeName: UIFont.appFontOfSize(15.0, weight: .Regular), NSParagraphStyleAttributeName: paragraphStyle]
				let attributedString = NSAttributedString(string: detailsString, attributes: attributes)
				detailsLabel.attributedText = attributedString
				
				detailsLabel.hidden = false
			} else {
				backgroundColor = UIColor.grayColor()
				titleLabel.text = "You're offline."
				subtitleLabel.text = "tap to go online".uppercaseString
				detailsLabel.hidden = true
			}
		}
	}
	var titleLabel: UILabel
	var subtitleLabel: UILabel
	var detailsLabel: UILabel
	
	override init(frame: CGRect) {
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		detailsLabel = UILabel()
		
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		backgroundColor = UIColor.grayColor()
		
		titleLabel.text = "Loading..."
		titleLabel.font = UIFont.appFontOfSize(18.0, weight: .Medium)
		titleLabel.textColor = UIColor.whiteColor()
		addSubview(titleLabel)
		
		subtitleLabel.font = UIFont.appFontOfSize(16.0, weight: .Regular)
		subtitleLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
		subtitleLabel.textAlignment = .Right
		addSubview(subtitleLabel)
		
		detailsLabel.font = UIFont.appFontOfSize(15.0, weight: .Regular)
		detailsLabel.textColor = UIColor.appTintColor().darkerColor(0.6)
		detailsLabel.numberOfLines = 3
		addSubview(detailsLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let margin = CGFloat(20)
		let subtitleWidth = CGFloat(180)
		titleLabel.frame = CGRectMake(margin, margin, frame.width - margin * 3.0 - subtitleWidth, 25)
		subtitleLabel.frame = CGRectMake(titleLabel.frame.maxX + margin, titleLabel.frame.minY, subtitleWidth, 25)
		detailsLabel.frame = CGRectMake(margin, titleLabel.frame.maxY + 10, frame.width - margin * 2.0, frame.height - titleLabel.frame.maxY - margin - 10)
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.backgroundColor = self.backgroundColor?.darkerColor(0.1)
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.backgroundColor = self.backgroundColor?.lighterColor(0.1)
		delegate?.dashboardStatusViewTapped(self)
	}
	
	class func heightForPost(post: Post?) -> CGFloat {
		if post != nil && post!.active {
			return 150
		} else {
			return 65
		}
	}
}
