//
//  HistoryDetailStatusCell.swift
//  Nibble
//
//  Created by Varun Arora on 11/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import Foundation

class HistoryDetailStatusCell: UITableViewCell {
    var statusText: String? {
        didSet {
            textLabel?.text = statusText
            if (textLabel?.text == "Cancelled") {
                line.backgroundColor = UIColor.redColor()
                circle.backgroundColor = UIColor.redColor()
            } else {
                line.backgroundColor = UIColor.appTintColor()
                circle.backgroundColor = UIColor.appTintColor()
            }
        }
    }
    
    // Status icon
    var line: UIView
    var circle: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        line = UIView()
        circle = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
		textLabel?.font = UIFont.appFontOfSize(16, weight: .Regular)
		textLabel?.textColor = UIColor.blackColor()
        addSubview(line)
		circle.clipsToBounds = true
        addSubview(circle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
		let margin = CGFloat(20)
		let circleDiameter = CGFloat(15)
		line.frame = CGRectMake(margin, 0, 1, frame.height)
		circle.frame = CGRectMake(line.frame.minX - circleDiameter / 2, frame.height / 2 - circleDiameter / 2, circleDiameter, circleDiameter)
		
		circle.layer.cornerRadius = circle.frame.width / 2
		
        textLabel?.frame = CGRectMake(circle.frame.maxX + margin, 0, frame.width - circle.frame.maxX, frame.height)
    }
    
}