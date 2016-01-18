//
//  OrderViewController.swift
//  Nibble
//
//  Created by Sachin on 11/9/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import CoreLocation

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OrderTextEntryCellDelegate {
	let textEntryCellIdentifier = "OrderTextEntryCell"
	let locationCellIdentifier = "UITableViewCell"
	
	var normalTitle: String
	
	var locations: [Location]
	var selectedLocations: [String]
	
	var order: Order?
	var posts: [Post] {
		didSet {
			for post in posts {
				if locations.contains(post.deliveryLocation) == false {
					locations.append(post.deliveryLocation)
				}
			}
			locations.sortInPlace { (a, b) -> Bool in
				if let currentLocation = CurrentLocation.sharedInstance.lastLocation {
					let aCoordinate = a.coordinate
					let bCoordinate = b.coordinate
					let aLocation = CLLocation(latitude: aCoordinate.latitude, longitude: aCoordinate.longitude)
					let bLocation = CLLocation(latitude: bCoordinate.latitude, longitude: bCoordinate.longitude)
					let aDistance = aLocation.distanceFromLocation(currentLocation)
					let bDistance = bLocation.distanceFromLocation(currentLocation)
					return aDistance < bDistance
				}
				return false
			}
			tableView.reloadData()
		}
	}
	
	// MARK: - UI
	var tableView: UITableView
	var darkeningView: UIView
	var orderButton: UIButton
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		normalTitle = ""
		
		posts = [Post]()
		locations = [Location]()
		selectedLocations = [String]()
		
		tableView = UITableView(frame: CGRectZero, style: .Grouped)
		darkeningView = UIView()
		orderButton = UIButton.appSquaredButton()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	convenience init(restaurant: Location) {
		self.init(nibName: nil, bundle: nil)
		
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		
		orderButton.setTitle("Place Order", forState: .Normal)
		orderButton.setTitle("Pick at least one delivery location.", forState: .Disabled)
		orderButton.addTarget(self, action: "placeOrder", forControlEvents: .TouchUpInside)
		orderButton.enabled = false
		view.addSubview(orderButton)

		tableView.dataSource = self
		tableView.delegate = self
		tableView.backgroundColor = UIColor.clearColor()
		tableView.alwaysBounceVertical = true
		tableView.showsVerticalScrollIndicator = false
		tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
		tableView.registerClass(OrderTextEntryCell.self, forCellReuseIdentifier: textEntryCellIdentifier)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: locationCellIdentifier)
		view.addSubview(tableView)
		
		darkeningView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
		darkeningView.alpha = 0.0
		tableView.addSubview(darkeningView)
	}
	
	// MARK: - View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Cancel button
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let orderButtonHeight = CGFloat(60)
		orderButton.frame = CGRectMake(0, view.frame.height - orderButtonHeight, view.frame.width, orderButtonHeight)
		tableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - orderButtonHeight)
		
		var textViewHeight = self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
		if darkeningView.alpha == 0.0 {
			textViewHeight = 0.0
		}
		darkeningView.frame = CGRectMake(0, textViewHeight - tableView.contentInset.top, view.frame.width, 1000)
	}
	
	// MARK: - UITableView
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0: return 1
			case 1: return locations.count
			default: return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cellIdentifier = ""
		switch indexPath.section {
			case 0: cellIdentifier = textEntryCellIdentifier
			case 1: cellIdentifier = locationCellIdentifier
			default: assert(cellIdentifier != "", "Invalid index path")
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		
		if let entryCell = cell as? OrderTextEntryCell {
			entryCell.delegate = self
			entryCell.selectionStyle = .None
			
			let gestureRecognizer = UITapGestureRecognizer(target: entryCell.textView, action: "resignFirstResponder")
			darkeningView.addGestureRecognizer(gestureRecognizer)
		} else {
			cell.textLabel?.font = UIFont.appFontOfSize(18.0, weight: .Regular)
			cell.textLabel?.text = locations[indexPath.row].name
			cell.accessoryType = selectedLocations.contains(locations[indexPath.row].objectId!) ? .Checkmark : .None
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
			case 0: return 150
			default: return 60
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30.0
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 35.0
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 1 {
			let sectionHeaderView = OrderPickupView()
			sectionHeaderView.leftLabel.text = "Pickup at".uppercaseString
			
			let deliveryTime = posts[0].deliveryTime
			let formatter = NSDateFormatter()
			formatter.dateFormat = "h:mm a"
			formatter.timeZone = NSTimeZone(name: "PST")
			sectionHeaderView.rightLabel.text = formatter.stringFromDate(deliveryTime)
			
			return sectionHeaderView
		}
		return nil
	}
	
	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if indexPath.section == 1 {
			let id = locations[indexPath.row].objectId!
			if selectedLocations.contains(id) {
				selectedLocations.removeAtIndex(selectedLocations.indexOf(id)!)
			} else {
				selectedLocations.append(id)
			}
			
			refreshOrderButton()
			tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
		}
	}
	
	// MARK: - OrderTextEntryCellDelegate
	func textEntryCellDidBeginEditing(cell: OrderTextEntryCell) {
		normalTitle = self.title!
		title = "Edit Order"
		navigationItem.setLeftBarButtonItem(nil, animated: true)
		navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Done, target: cell.textView, action: "resignFirstResponder"), animated: true)
		
		view.setNeedsLayout()
		UIView.animateWithDuration(0.15) { () -> Void in
			self.darkeningView.alpha = 1.0
		}
	}
	
	func textEntryCellDidEndEditing(cell: OrderTextEntryCell) {
		self.title = normalTitle
		navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel"), animated: true)
		navigationItem.setRightBarButtonItem(nil, animated: true)
		
		UIView.animateWithDuration(0.15, animations: { () -> Void in
			self.darkeningView.alpha = 0.0
		}) { (done) -> Void in
			self.view.setNeedsLayout()
		}
	}
	
	func textEntryCell(cell: OrderTextEntryCell, textDidChange text: String) {
		order?.text = text
		refreshOrderButton()
	}
	
	// MARK - More
	func refreshOrderButton() {
		let validLocations = selectedLocations.count > 0
		let validText = order?.text.characters.count > 0
		if validLocations == false {
			orderButton.setTitle("Pick at least one delivery location.", forState: .Disabled)
		} else if validText == false {
			orderButton.setTitle("Please type your order above.", forState: .Disabled)
		}
		orderButton.enabled = validLocations && validText
	}
	
	func cancel() {
		if order?.text.characters.count > 0 {
			let alertController = UIAlertController(title: nil, message: "Are you sure you want to cancel?", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
				alertController.dismissViewControllerAnimated(true, completion: nil)
				self.dismissViewControllerAnimated(true, completion: nil)
			}))
			alertController.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
				alertController.dismissViewControllerAnimated(true, completion: nil)
			}))
			self.presentViewController(alertController, animated: true, completion: nil)
		} else {
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	func placeOrder() {
		// Add requested posts
		for post in posts {
			for locationID in selectedLocations {
				if post.deliveryLocation.objectId! == locationID {
					order?.requestedPosts.addObject(post)
				}
			}
		}
		
		// Save in background
		order?.saveInBackgroundWithBlock { (booleanResult, error) -> Void in
			if error != nil {
				let alertController = UIAlertController(title: "Error placing order", message: "There was an error placing your order.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}
		
		// Show confirmed view controller
		let confirmedViewController = OrderConfirmedViewController()
		navigationController?.pushViewController(confirmedViewController, animated: true)
	}
}
