//
//  RestaurantTitleCell.swift
//  Nibble
//
//  Created by Sachin on 11/18/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class RestaurantTitleCell: UITableViewCell {
	var restaurant: Location? {
		didSet {
			titleLabel.text = restaurant!.name
			subtitleLabel.text = "\(restaurant!.categoryString), \(restaurant!.priceTier)"
			ratingView.rating = restaurant!.rating.floatValue
		}
	}
	
	var titleLabel: UILabel
	var subtitleLabel: UILabel
	var ratingView: CircleRatingView
	
	// MARK: Initialization
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		ratingView = CircleRatingView()
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	func commonInit() {		
		titleLabel.font = UIFont.appFontOfSize(22, weight: .Regular)
		titleLabel.textColor = UIColor.blackColor()
		titleLabel.textAlignment = .Center
		contentView.addSubview(titleLabel)
		
		subtitleLabel.font = UIFont.appFontOfSize(18, weight: .Light)
		subtitleLabel.textColor = UIColor.lightGrayColor()
		subtitleLabel.textAlignment = .Center
		contentView.addSubview(subtitleLabel)
		
		contentView.addSubview(ratingView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
		subtitleLabel.text = nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let margin = CGFloat(22)
		let ratingViewSize = CGFloat(35)
		titleLabel.frame = CGRectMake(0, margin, contentView.frame.width, 30)
		subtitleLabel.frame = CGRectMake(0, titleLabel.frame.maxY + 3, contentView.frame.width, 20)
		ratingView.frame = CGRectMake((frame.width - ratingViewSize) / 2.0, subtitleLabel.frame.maxY + 8, ratingViewSize, ratingViewSize)
	}
}
