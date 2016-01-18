//
//  LocationPickerCell.swift
//  Nibble Driver
//
//  Created by Sachin on 10/24/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

class LocationPickerCell: UITableViewCell {
	var location: Location {
		didSet {
			nameLabel.text = location.name
			if let address = location.address {
				addressLabel.text = address
			}
		}
	}
	
	var nameLabel: UILabel
	var addressLabel: UILabel
	
	// MARK: Initialization
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		location = Location()
		nameLabel = UILabel()
		addressLabel = UILabel()
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	func commonInit() {
		backgroundColor = UIColor.whiteColor()
		
		nameLabel.font = UIFont.appFontOfSize(16, weight: .Regular)
		contentView.addSubview(nameLabel)
		
		addressLabel.font = UIFont.appFontOfSize(13, weight: .Regular)
		addressLabel.textColor = UIColor.lightGrayColor()
		contentView.addSubview(addressLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		nameLabel.text = ""
		addressLabel.text = ""
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		nameLabel.frame = CGRectMake(layoutMargins.left, 20, contentView.frame.width - layoutMargins.left - layoutMargins.right, 20)
		addressLabel.frame = CGRectMake(layoutMargins.left, nameLabel.frame.maxY + 2, contentView.frame.width - layoutMargins.left - layoutMargins.right, 20)
	}
}
