//
//  OrderPairCell.swift
//  Nibble
//
//  Created by Sachin on 11/9/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class OrderPairCell: UITableViewCell {
	var nameLabel: UILabel
	var subtitleLabel: UILabel
	
	// MARK: Initialization
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		nameLabel = UILabel()
		subtitleLabel = UILabel()
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	func commonInit() {
		self.contentView.backgroundColor = UIColor.whiteColor()
		
		nameLabel.font = UIFont.appFontOfSize(18, weight: .Light)
		contentView.addSubview(nameLabel)
		
		subtitleLabel.font = UIFont.appFontOfSize(15, weight: .Light)
		subtitleLabel.textColor = UIColor.lightGrayColor()
		contentView.addSubview(subtitleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		nameLabel.text = nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let margin = CGFloat(15)
		nameLabel.frame = CGRectMake(margin, margin, contentView.frame.width - margin * 2, 25)
		subtitleLabel.frame = CGRectMake(margin, nameLabel.frame.maxY, nameLabel.frame.width, 20)
	}
}
