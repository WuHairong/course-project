//
//  NibbleLogoView.swift
//  Nibble
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class NibbleLogoView: UIView {
	var imageView: UIImageView
	var label: UILabel
	
	override init(frame: CGRect) {
		imageView = UIImageView()
		label = UILabel()

		super.init(frame: frame)

		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func commonInit() {
		imageView.image = UIImage(named: "Logo")
		imageView.contentMode = .ScaleAspectFit
		addSubview(imageView)
		
		label.font = UIFont.appFontOfSize(30.0, weight: .Medium)
		label.textAlignment = .Center
		addSubview(label)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRectMake(0, 0, frame.width, 100.0)
		label.frame = CGRectMake(0, imageView.frame.maxY + 25.0, frame.width, 30.0)
	}

	class func preferredContentSize() -> CGSize {
		return CGSizeMake(200.0, 155.0)
	}
}
