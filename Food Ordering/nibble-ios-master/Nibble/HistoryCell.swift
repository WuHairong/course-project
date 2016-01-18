//
//  HistoryCell.swift
//  Nibble
//
//  Created by Varun Arora on 10/28/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Foundation

class HistoryCell: UITableViewCell {
    // MARK: Properties
    var order: Order {
        didSet {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, yyyy, h:mm a"
            formatter.timeZone = NSTimeZone(name: "PST")
            if let createdAtDate = order.createdAt {
                orderDateLabel.text = formatter.stringFromDate(createdAtDate)
            }
            
            restaurantLabel.text = order.restaurant.name

        }
    }
    var orderDateLabel: UILabel
    var restaurantLabel: UILabel
	
    // MARK: Init
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		order = Order()
		orderDateLabel = UILabel()
		restaurantLabel = UILabel()
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    func commonInit() {
        restaurantLabel.font = UIFont.appFontOfSize(18, weight: .Medium)
        contentView.addSubview(restaurantLabel)
        
        orderDateLabel.font = UIFont.appFontOfSize(15, weight: .Regular)
        orderDateLabel.textColor = UIColor.darkGrayColor()
        contentView.addSubview(orderDateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
		let margin = CGFloat(15)
        restaurantLabel.frame = CGRect(x: margin, y: 20, width: frame.width, height: 35)
        orderDateLabel.frame = CGRect(x: margin, y: restaurantLabel.frame.maxY, width: frame.width, height: 15)
    }

    // MARK: Methods
    override func prepareForReuse() {
		super.prepareForReuse()
        orderDateLabel.text = nil
        restaurantLabel.text = nil
    }
}