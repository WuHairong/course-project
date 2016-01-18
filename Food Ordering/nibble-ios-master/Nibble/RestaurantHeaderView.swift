//
//  RestaurantHeaderView.swift
//  Nibble
//
//  Created by Sachin on 10/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

import SDWebImage

protocol RestaurantHeaderViewDelegate {
	func back()
}

class RestaurantHeaderView: UIView {
	var delegate: RestaurantHeaderViewDelegate?
	var restaurant: Location {
		didSet {
			dispatch_async(dispatch_get_main_queue(), {
				SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: self.restaurant.thumbnailURL), options: SDWebImageOptions(), progress: nil, completed: { (image, error, cacheType, finished, url) -> Void in
					if let finishedImage = image {
						self.kenBurnsView.animateWithImages([finishedImage], transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
						self.downloadImages()
					}
				})
			})
		}
	}
	
	var kenBurnsView: JBKenBurnsView
	var darkeningLayer: CAGradientLayer
	var backButton: UIButton
	
	override init(frame: CGRect) {
		kenBurnsView = JBKenBurnsView()
		darkeningLayer = CAGradientLayer()
		
		backButton = UIButton()
		
		restaurant = Location()
		
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func commonInit() {
		backgroundColor = UIColor.blackColor()
		clipsToBounds = true
		
		let darkBlack = UIColor.blackColor().colorWithAlphaComponent(0.8)
		let lightBlack = UIColor.blackColor().colorWithAlphaComponent(0.5)
		let veryLightBlack = UIColor.blackColor().colorWithAlphaComponent(0.1)
		darkeningLayer.colors = [darkBlack.CGColor, lightBlack.CGColor, veryLightBlack.CGColor, UIColor.clearColor().CGColor]
		darkeningLayer.locations = [0.0, 0.05, 0.4, 1.0]
		addSubview(kenBurnsView)
		layer.addSublayer(darkeningLayer)

		backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
		backButton.setImage(UIImage(named: "Back"), forState: .Normal)
		addSubview(backButton)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let buttonSize = CGFloat(44)
		kenBurnsView.frame = CGRectMake(0, 0, frame.width, frame.height * 1.5)
		darkeningLayer.frame = kenBurnsView.frame
		backButton.frame = CGRectMake(0, 30, buttonSize, buttonSize)
	}
	
	func downloadImages() {
		dispatch_async(dispatch_get_main_queue(), {
			let query = self.restaurant.photos.query()
			query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
				if let photos = results as? [Photo] {
					var photosWithoutFirst = photos
					photosWithoutFirst.removeFirst()
					for photo in photosWithoutFirst {
						SDWebImageManager.sharedManager().downloadImageWithURL(photo.url(), options: SDWebImageOptions(), progress: nil, completed: { (image, error, cacheType, finished, url) -> Void in
							if let finishedImage = image {
								self.kenBurnsView.addImage(finishedImage)
							}
						})
					}
				}
			})
		})
	}
	
	func back() {
		delegate?.back()
	}
}
