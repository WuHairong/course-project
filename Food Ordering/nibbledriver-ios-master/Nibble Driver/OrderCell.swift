//
//  OrderCell.swift
//  Nibble Driver
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

protocol OrderCellDelegate {
	func orderCell(cell: OrderCell, didIgnoreOrder order: Order)
	func orderCell(cell: OrderCell, didAcceptOrder order: Order)
	func orderCell(cell: OrderCell, didPickUpOrder order: Order)
	func orderCell(cell: OrderCell, didDeliverOrder order: Order)
}

struct OrderCellConstants {
	private static let titleHeight = CGFloat(20)
	private static let buttonHeight = CGFloat(50)
	private static let margin = CGFloat(25)
	private static let checklistItemHeight = CGFloat(25)
}

class OrderCell: UICollectionViewCell, OrderChecklistItemViewDelegate {
	var delegate: OrderCellDelegate?
	var order: Order {
		didSet {
			titleLabel.text = "\(order.user.firstName)'s Order"
			
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 15
			let attributes = [NSFontAttributeName: UIFont.appFontOfSize(16.0, weight: .Regular), NSParagraphStyleAttributeName: paragraphStyle]
			let attributedString = NSAttributedString(string: order.text, attributes: attributes)
			orderTextLabel.attributedText = attributedString
			
			pickedUpItem.checked = order.pickedUp
			deliveredItem.checked = order.delivered
			
			setNeedsLayout()
		}
	}
	
	var titleLabel: UILabel
	var orderTextLabel: UILabel
	
	var acceptButton: UIButton
	var ignoreButton: UIButton
	
	var overlayView: UIView
	var separator: UIView
	var topLine: UIView
	var bottomLine: UIView
	
	var pickedUpItem: OrderChecklistItemView
	var deliveredItem: OrderChecklistItemView
	
	// MARK: Initialization
	override init(frame: CGRect) {
		order = Order()
		
		titleLabel = UILabel()
		orderTextLabel = UILabel()
		
		acceptButton = UIButton.roundedButtonWithColor(UIColor.appTintColor())
		ignoreButton = UIButton.roundedButtonWithColor(UIColor.lightGrayColor())
		
		overlayView = UIView()
		separator = UIView()
		topLine = UIView()
		bottomLine = UIView()
		
		pickedUpItem = OrderChecklistItemView()
		deliveredItem = OrderChecklistItemView()
		
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		self.contentView.backgroundColor = UIColor.whiteColor()

		titleLabel.font = UIFont.appFontOfSize(18, weight: .Regular)
		contentView.addSubview(titleLabel)

		orderTextLabel.font = UIFont.appFontOfSize(16, weight: .Regular)
		orderTextLabel.textColor = UIColor.lightGrayColor()
		orderTextLabel.numberOfLines = 0
		orderTextLabel.lineBreakMode = .ByWordWrapping
		contentView.addSubview(orderTextLabel)
		
		ignoreButton.addTarget(self, action: "ignoreOrder", forControlEvents: .TouchUpInside)
		ignoreButton.setTitle("Ignore", forState: .Normal)
		ignoreButton.clipsToBounds = true
		contentView.addSubview(ignoreButton)
		
		acceptButton.addTarget(self, action: "acceptOrder", forControlEvents: .TouchUpInside)
		acceptButton.setTitle("Accept", forState: .Normal)
		acceptButton.clipsToBounds = true
		contentView.addSubview(acceptButton)
		
		separator.backgroundColor = UIColor.appSeparatorColor()
		contentView.addSubview(separator)
		
		pickedUpItem.label.text = "Pick up order"
		pickedUpItem.delegate = self
		pickedUpItem.clipsToBounds = true
		contentView.addSubview(pickedUpItem)
		
		deliveredItem.label.text = "Deliver order"
		deliveredItem.delegate = self
		deliveredItem.clipsToBounds = true
		contentView.addSubview(deliveredItem)
		
		overlayView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
		overlayView.clipsToBounds = true
		contentView.addSubview(overlayView)
		
		topLine.backgroundColor = UIColor.lightGrayColor()
		bottomLine.backgroundColor = UIColor.lightGrayColor()
		contentView.addSubview(topLine)
		contentView.addSubview(bottomLine)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Methods
	override func prepareForReuse() {
		super.prepareForReuse()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let orderTextHeight = OrderCell.orderTextLabelHeightForText(order.text, width: frame.width)
		
		let titleHeight = OrderCellConstants.titleHeight
		let margin = OrderCellConstants.margin
		let buttonHeight = OrderCellConstants.buttonHeight
		let checklistItemHeight = OrderCellConstants.checklistItemHeight
		let lineWidth = 1.0 / UIScreen.mainScreen().scale
		
		titleLabel.frame = CGRectMake(margin, margin, frame.width - margin * 2, titleHeight)
		orderTextLabel.frame = CGRectMake(margin, titleLabel.frame.maxY + margin, frame.width - margin * 2, orderTextHeight)
		
		acceptButton.frame = CGRectZero
		ignoreButton.frame = CGRectZero
		separator.frame = CGRectZero
		pickedUpItem.frame = CGRectZero
		deliveredItem.frame = CGRectZero
		if order.assignedPost.objectId != nil {
			// Show checklist
			separator.frame = CGRectMake(margin, orderTextLabel.frame.maxY + margin, frame.width - margin * 2, lineWidth)
			pickedUpItem.frame = CGRectMake(margin, separator.frame.maxY + margin, frame.width - margin * 2, checklistItemHeight)
			deliveredItem.frame = CGRectMake(margin, pickedUpItem.frame.maxY + margin, frame.width - margin * 2, checklistItemHeight)
		} else {
			// Show buttons
			ignoreButton.frame = CGRectMake(margin, orderTextLabel.frame.maxY + margin, (frame.width - margin * 3) / 2.0, buttonHeight)
			acceptButton.frame = CGRectMake(ignoreButton.frame.maxX + margin, orderTextLabel.frame.maxY + margin, (frame.width - margin * 3) / 2.0, buttonHeight)
		}
		
		topLine.frame = CGRectMake(0, 0, frame.width, lineWidth)
		bottomLine.frame = CGRectMake(0, frame.height - lineWidth, frame.width, lineWidth)
		
		if order.delivered {
			overlayView.frame = contentView.frame
		} else {
			overlayView.frame = CGRectZero
		}
	}
	
	// MARK: - OrderChecklistItemViewDelegate
	func checklistItemViewDidTapCheckbox(view: OrderChecklistItemView) {
		if view == pickedUpItem {
			delegate?.orderCell(self, didPickUpOrder: order)
		} else if view == deliveredItem {
			delegate?.orderCell(self, didDeliverOrder: order)
		}
	}
	
	// MARK: - Cell actions
	func ignoreOrder() {
		delegate?.orderCell(self, didIgnoreOrder: order)
	}
	
	func acceptOrder() {
		delegate?.orderCell(self, didAcceptOrder: order)
	}
	
	// MARK: - Cell sizing
	class func cellHeightForOrder(order: Order, width: CGFloat) -> CGFloat {
		let margin = OrderCellConstants.margin
		let titleHeight = OrderCellConstants.titleHeight
		let buttonHeight = OrderCellConstants.buttonHeight
		let checklistItemHeight = OrderCellConstants.checklistItemHeight
		let labelHeight = OrderCell.orderTextLabelHeightForText(order.text, width: width)
		let separatorHeight = 1.0 / UIScreen.mainScreen().scale
		
		if order.assignedPost.objectId != nil {
			// Checklist
			return margin + titleHeight + margin + labelHeight + margin + separatorHeight + margin + checklistItemHeight + margin + checklistItemHeight + margin
		} else {
			// Buttons
			return margin + titleHeight + margin + labelHeight + margin + buttonHeight + margin
		}
	}
	
	class func orderTextLabelHeightForText(text: String, width: CGFloat) -> CGFloat {
		let margin = OrderCellConstants.margin
		let size = CGSizeMake(width - margin * 2, CGFloat.max)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 15
		let attributes = [NSFontAttributeName: UIFont.appFontOfSize(16.0, weight: .Regular), NSParagraphStyleAttributeName: paragraphStyle]
		
		let labelSize = (text as NSString).boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
		return labelSize.height
	}
}
