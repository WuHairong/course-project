//
//  DeliveringAtViewController.swift
//  Nibble Driver
//
//  Created by Sachin on 10/26/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit
import Parse

class DeliveringAtViewController: UIViewController {
	var context: [String: AnyObject]?
	var datePicker: UIDatePicker
	var continueButton: UIButton
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		datePicker = UIDatePicker()
		continueButton = UIButton.appSquaredButton()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		
		datePicker.backgroundColor = UIColor.whiteColor()
		datePicker.datePickerMode = .Time
		datePicker.minuteInterval = 15
		
		let earliestTime = NSDate.withHours(7, m: 00, PM: false)
		let now = NSDate()
		datePicker.minimumDate = now.compare(earliestTime) == NSComparisonResult.OrderedAscending ? earliestTime : now
		datePicker.maximumDate = NSDate.withHours(11, m: 59, PM: true)
		
		view.addSubview(datePicker)
		
		view.addSubview(continueButton)
	}
	
	// MARK: - View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Delivering At"
		
		continueButton.setTitle("Go Online", forState: .Normal)
		continueButton.addTarget(self, action: "uploadLocationsAndCreate", forControlEvents: .TouchUpInside)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let datePickerHeight = CGFloat(200)
		datePicker.frame = CGRectMake(0, ((view.frame.height - datePickerHeight) / 2) - 44, view.frame.width, datePickerHeight)
		
		let continueButtonHeight = CGFloat(60)
		continueButton.frame = CGRectMake(0, view.frame.height - continueButtonHeight, view.frame.width, continueButtonHeight)
	}
	
	func uploadLocationsAndCreate() {
		continueButton.enabled = false
		
		// Create locations on Parse + create post
		if let deliveringFromLocation = self.context!["deliveringFrom"] as? Location,
		   let deliveringToLocation = self.context!["deliveringTo"] as? Location {
			Foursquare.completeVenueAndSave(deliveringFromLocation) { (location, error) -> () in
				Foursquare.completeVenueAndSave(deliveringToLocation) { (location, error) -> () in
					self.createPost()
				}
			}
		}
		
		// Show confirmed view controller
		let confirmedViewController = PostConfirmedViewController()
		navigationController?.pushViewController(confirmedViewController, animated: true)
	}
	
	func createPost() {
		let post = Post()
		post.active = true
		
		if let restaurant = context!["deliveringFrom"] as? Location {
			let restaurantPointer = Location(withoutDataWithObjectId: restaurant.objectId)
			post.restaurant = restaurantPointer
		}
		
		if let deliveryLocation = context!["deliveringTo"] as? Location {
			let deliveryLocationPointer = Location(withoutDataWithObjectId: deliveryLocation.objectId)
			post.deliveryLocation = deliveryLocationPointer
		}
		
		// Zero out datePicker seconds
		var date = datePicker.date
		let timeInterval = floor(date.timeIntervalSinceReferenceDate / 60.0) * 60.0
		date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
		
		post.deliveryTime = date
		post.saveInBackgroundWithBlock { (success, error) -> Void in
			NSNotificationCenter.defaultCenter().postNotificationName("RefreshDashboard", object: nil)
		}
	}
}
