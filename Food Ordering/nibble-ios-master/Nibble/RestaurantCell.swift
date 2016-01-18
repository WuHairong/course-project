//
//  RestaurantCell.swift
//  Nibble
//
//  Created by Varun Arora on 10/16/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import SDWebImage

struct RestaurantCellConstants {
	static let imageHeight = CGFloat(230)
	static let imageOffsetSpeed = CGFloat(70)
	private static let imageContainerHeight = CGFloat(140)
	private static let margin = CGFloat(15)
	private static let ratingViewEdge = CGFloat(35)
	private static let nameHeight = CGFloat(25)
	private static let subtitleHeight = CGFloat(20)
}

class RestaurantCell: UICollectionViewCell {
    // MARK: Properties
	var restaurant: Location {
		didSet {
			if restaurant.thumbnailURL.characters.count > 0 {
				dispatch_async(dispatch_get_main_queue(), {
					self.imageView.sd_setImageWithURL(NSURL(string: self.restaurant.thumbnailURL)!)
				})
			}
			ratingView.rating = restaurant.rating.floatValue
            nameLabel.text = restaurant.name
			subtitleLabel.text = "\(restaurant.categoryString), \(restaurant.priceTier)"
		}
	}
	
	var imageContainerView: UIView
	var imageView: UIImageView
	var imageOffset: CGPoint {
		didSet {
			setNeedsLayout()
		}
	}
    
    var nameLabel: UILabel
	var subtitleLabel: UILabel
	var ratingView: CircleRatingView
		
    // MARK: Initialization
	override init(frame: CGRect) {
		imageOffset = CGPointZero
		restaurant = Location()
		nameLabel = UILabel()
		subtitleLabel = UILabel()
		imageContainerView = UIView()
		imageView = UIImageView()
		ratingView = CircleRatingView()
		
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		self.contentView.backgroundColor = UIColor.whiteColor()
		
		imageContainerView.backgroundColor = UIColor.clearColor()
		imageContainerView.clipsToBounds = true
		contentView.addSubview(imageContainerView)
		
		imageView.backgroundColor = UIColor.appBackgroundColor()
		imageView.contentMode = .ScaleAspectFill
		imageView.clipsToBounds = false
		imageContainerView.addSubview(imageView)
		
		nameLabel.font = UIFont.appFontOfSize(18, weight: .Regular)
		contentView.addSubview(nameLabel)
		
		subtitleLabel.font = UIFont.appFontOfSize(15, weight: .Regular)
		subtitleLabel.textColor = UIColor.lightGrayColor()
		contentView.addSubview(subtitleLabel)
		
		contentView.addSubview(ratingView)
		
		// Add shadow
		layer.masksToBounds = false
		let shadowPath = UIBezierPath(rect: bounds)
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOffset = CGSizeZero
		layer.shadowOpacity = 0.2
		layer.shadowRadius = 2.0
		layer.shadowPath = shadowPath.CGPath
	}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
		nameLabel.text = nil
		ratingView.rating = 0.0
		imageOffset = CGPointZero
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
		let margin = RestaurantCellConstants.margin
		let ratingViewEdge = RestaurantCellConstants.ratingViewEdge
		let imageHeight = RestaurantCellConstants.imageHeight
		let imageContainerHeight = RestaurantCellConstants.imageContainerHeight
		let nameHeight = RestaurantCellConstants.nameHeight
		let subtitleHeight = RestaurantCellConstants.subtitleHeight
		imageContainerView.frame = CGRectMake(0, 0, contentView.frame.width, imageContainerHeight)
        nameLabel.frame = CGRectMake(margin, imageContainerHeight + margin, contentView.frame.width - margin * 4 - ratingViewEdge, nameHeight)
		subtitleLabel.frame = CGRectMake(nameLabel.frame.minX, nameLabel.frame.maxY, nameLabel.frame.width, subtitleHeight)
		ratingView.frame = CGRectMake(contentView.frame.width - ratingViewEdge - margin, imageContainerHeight + ((contentView.frame.height - imageContainerHeight - ratingViewEdge) / 2.0), ratingViewEdge, ratingViewEdge)
		
		// Parallax image view
		let centerY = CGFloat((imageHeight - imageContainerHeight) / 2.0)
		let frame = CGRectMake(-20, -centerY, imageContainerView.frame.width + 20, imageHeight)
		let offsetFrame = CGRectOffset(frame, imageOffset.x, imageOffset.y)
		imageView.frame = offsetFrame
    }
}
