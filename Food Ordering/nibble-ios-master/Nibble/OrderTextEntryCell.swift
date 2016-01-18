//
//  OrderTextEntryCell.swift
//  Nibble
//
//  Created by Sachin on 11/9/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

protocol OrderTextEntryCellDelegate {
	func textEntryCellDidBeginEditing(cell: OrderTextEntryCell)
	func textEntryCellDidEndEditing(cell: OrderTextEntryCell)
	func textEntryCell(cell: OrderTextEntryCell, textDidChange text: String)
}

class OrderTextEntryCell: UITableViewCell, UITextViewDelegate {
	var textView: UITextView
	var delegate: OrderTextEntryCellDelegate?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		textView = UITextView()
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	func commonInit() {
		textView.font = UIFont.appFontOfSize(20.0, weight: .Regular)
		textView.placeholder = "Enter your order here..."
		textView.delegate = self
		contentView.addSubview(textView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		textView.text = ""
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		textView.frame = CGRectInset(contentView.frame, 10.0, 10.0)
	}
	
	// MARK: UITextViewDelegate
	func textViewDidBeginEditing(textView: UITextView) {
		delegate?.textEntryCellDidBeginEditing(self)
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		delegate?.textEntryCellDidEndEditing(self)
	}
	
	func textViewDidChange(textView: UITextView) {
		delegate?.textEntryCell(self, textDidChange: textView.text)
	}
}
