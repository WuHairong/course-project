//
//  HistoryDetailLocationCell.swift
//  Nibble
//
//  Created by Varun Arora on 11/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import Foundation

class HistoryDetailLocationCell: UITableViewCell {
    var locationTitle: String? {
        didSet {
            textLabel?.text = locationTitle
        }
    }
    var location: Location? {
        didSet {
            if (location?.name.characters.count > 0) {
                locationLabel.text = location?.name
                accessoryType = .DisclosureIndicator
            } else if (cancelled == true) {
                locationLabel.text = "Cancelled"
                locationLabel.textColor = UIColor.grayColor()
                selectionStyle = .None
            } else {
                locationLabel.text = "Pending"
                locationLabel.textColor = UIColor.grayColor()
                selectionStyle = .None
            }
        }
    }
    var locationLabel: UILabel
    var cancelled: Bool?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        locationLabel = UILabel()
		
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        textLabel?.font = UIFont.appFontOfSize(14, weight: .Regular)
        textLabel?.textColor = UIColor.grayColor()
        locationLabel.font = UIFont.appFontOfSize(16, weight: .Regular)
        locationLabel.textColor = UIColor.blackColor()
        contentView.addSubview(locationLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cellMargin = CGFloat(15)
        let subtitleY = contentView.center.y/2 - 14/4
        if (textLabel?.text?.characters.count > 0) {
            textLabel?.frame = CGRect(x: cellMargin, y: subtitleY, width: contentView.frame.width, height: contentView.frame.height/2)
        }
        
        locationLabel.frame = CGRect(x: cellMargin, y: contentView.frame.maxY/2, width: contentView.frame.width, height: contentView.frame.height/2)
    }
}
