//
//  RestaurantTimesCell.swift
//  Nibble
//
//  Created by Sachin on 11/2/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import CoreLocation

protocol RestaurantTimesCellDelegate {
	func restaurantTimesCell(cell: RestaurantTimesCell, didSelectDate date: NSDate)
}

struct RestaurantTimesCellConstants {
	private static let margin = CGFloat(15)
	private static let buttonSpacing = CGFloat(10)
	private static let buttonWidth = CGFloat(95)
	private static let buttonHeight = CGFloat(35)
}

class RestaurantTimesCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
	var delegate: RestaurantTimesCellDelegate?
	var posts: [[Post]] {
		didSet {
			dates = posts.map({ (postGroup) -> NSDate in
				return postGroup[0].deliveryTime
			})
			collectionView.reloadData()
		}
	}
	var dates: [NSDate]
	
	// Constants
	let cellHeight = CGFloat(44)
	let cellIdentifier = "RestaurantTimeButton"
	var collectionView: UICollectionView
	
	// MARK: Initialization
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		posts = [[Post]]()
		dates = [NSDate]()
		
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.minimumInteritemSpacing = RestaurantTimesCellConstants.buttonSpacing
		collectionViewLayout.minimumLineSpacing = RestaurantTimesCellConstants.buttonSpacing
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	func commonInit() {
		self.contentView.backgroundColor = UIColor.whiteColor()
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.backgroundColor = UIColor.clearColor()
		collectionView.scrollEnabled = false
		collectionView.userInteractionEnabled = false
		collectionView.registerClass(RestaurantTimeButton.self, forCellWithReuseIdentifier: cellIdentifier)
		contentView.addSubview(collectionView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let margin = RestaurantTimesCellConstants.margin
		collectionView.frame = CGRectMake(margin, margin, frame.width - margin * 2, frame.height - margin)
	}
	
	// MARK: - Methods
	class func heightForPosts(posts: [Post], inWidth width: CGFloat) -> CGFloat {
		let allDates = posts.map({ (post) -> NSDate in
			return post.deliveryTime
		})
		let dedupedDates = Array(Set(allDates)).sort({ (dateA, dateB) -> Bool in
			return dateA.compare(dateB) == NSComparisonResult.OrderedAscending
		})
		
		let margin = RestaurantTimesCellConstants.margin
		let buttonWidth = RestaurantTimesCellConstants.buttonWidth
		let buttonHeight = RestaurantTimesCellConstants.buttonHeight
		let buttonSpacing = RestaurantTimesCellConstants.buttonSpacing
		
		let buttonCountPerLine = floor((width - margin * 2) / (buttonWidth + buttonSpacing))
		let buttonLineCount = ceil(CGFloat(dedupedDates.count) / buttonCountPerLine)
		let collectionViewHeight = (buttonLineCount * buttonHeight) + ((buttonLineCount - 1) * buttonSpacing)
		
		return margin + collectionViewHeight + margin
	}
	
	// MARK: - Internal Collection View
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dates.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if let newCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? RestaurantTimeButton {
			newCell.date = dates[indexPath.row]
			return newCell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(RestaurantTimesCellConstants.buttonWidth, RestaurantTimesCellConstants.buttonHeight)
	}
	
	class func heightForPostCount(count: Int) -> CGFloat {
		let rowCount = CGFloat(ceil(Float(count) / 3.0))
		let height = RestaurantTimesCellConstants.margin + (RestaurantTimesCellConstants.buttonHeight * rowCount) + (RestaurantTimesCellConstants.buttonSpacing * (rowCount - 1)) + RestaurantTimesCellConstants.margin
		return height
	}
	
	// MARK: - Touch event handling (sketchy)
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		if let touch = touches.first {
			let location = touch.locationInView(collectionView)
			guard let indexPath = collectionView.indexPathForItemAtPoint(location) else { return }
			if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? RestaurantTimeButton {
				delegate?.restaurantTimesCell(self, didSelectDate: cell.date)
			}
		}
	}
}
