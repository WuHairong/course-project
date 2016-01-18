//
//  OrderChecklistItemView.swift
//  Nibble Driver
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

protocol OrderChecklistItemViewDelegate {
	func checklistItemViewDidTapCheckbox(view: OrderChecklistItemView)
}

class OrderChecklistItemView: UIView {
	var delegate: OrderChecklistItemViewDelegate?
	var checked: Bool {
		didSet {
			checkbox.selected = checked
		}
	}
	var checkbox: UIButton
	var label: UILabel
	
	override init(frame: CGRect) {
		checked = false
		checkbox = UIButton()
		label = UILabel()

		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleCheckbox")
		addGestureRecognizer(tapGestureRecognizer)
		
		checkbox.setImage(UIImage(named: "checkbox_unchecked"), forState: .Normal)
		checkbox.setImage(UIImage(named: "checkbox_checked"), forState: .Selected)
		checkbox.addTarget(self, action: "toggleCheckbox", forControlEvents: .TouchUpInside)
		addSubview(checkbox)
		
		label.font = UIFont.appFontOfSize(18.0, weight: .Regular)
		addSubview(label)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let margin = CGFloat(10)
		checkbox.frame = CGRectMake(0, 0, 25, 25)
		label.frame = CGRectMake(checkbox.frame.maxX + margin, 0, frame.width - checkbox.frame.maxX - margin, frame.height)
	}
	
	func toggleCheckbox() {
		delegate?.checklistItemViewDidTapCheckbox(self)
	}
}
