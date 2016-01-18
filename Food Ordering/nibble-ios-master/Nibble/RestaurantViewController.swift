//
//  RestaurantViewController.swift
//  Nibble
//
//  Created by Sachin on 10/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RestaurantHeaderViewDelegate, RestaurantTimesCellDelegate {
	// Constants
	let titleCellHeight = CGFloat(150)
	let normalCellHeight = CGFloat(55)
	
	let headerHeight = CGFloat(150)
	let topInteractiveHeight = CGFloat(80)
	
	let titleCellIdentifier = "RestaurantTitleCell"
	let timesCellIdentifier = "RestuarantTimesCell"
	let normalCellIdentifier = "UITableViewCell"
	
	// Model
	private var restaurant: Location
	var postsByTime: [[Post]]
	
	// UI
	var headerView: RestaurantHeaderView
	var tableView: UITableView
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		headerView = RestaurantHeaderView()
		tableView = UITableView(frame: CGRectZero, style: .Grouped)
		
		restaurant = Location()
		postsByTime = [[Post]]()
				
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	convenience init(restaurant: Location) {
		self.init(nibName: nil, bundle: nil)
		
		// Set restaurant and get posts
		self.restaurant = restaurant
		postsByTime.removeAll()
		
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
				
		headerView.restaurant = restaurant
		headerView.delegate = self
		view.addSubview(headerView)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.backgroundColor = UIColor.clearColor()
		tableView.alwaysBounceVertical = true
		tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
		tableView.showsVerticalScrollIndicator = false
		tableView.registerClass(RestaurantTitleCell.self, forCellReuseIdentifier: titleCellIdentifier)
		tableView.registerClass(RestaurantTimesCell.self, forCellReuseIdentifier: timesCellIdentifier)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: normalCellIdentifier)
		tableView.contentInset = UIEdgeInsetsMake(headerHeight - topInteractiveHeight, 0, 0, 0)
		view.addSubview(tableView)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Refresh when coming from background
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		refresh()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let calculatedHeaderHeight = max(headerHeight - tableView.contentOffset.y, headerHeight)
		headerView.frame = CGRectMake(0, 0, view.frame.width, calculatedHeaderHeight)
		tableView.frame = CGRectMake(0, topInteractiveHeight, view.frame.width, view.frame.height - topInteractiveHeight)
	}
	
	func refresh() {
		let postsQuery = restaurant.posts.query()
		postsQuery?.includeKey("deliveryLocation")
		postsQuery?.cachePolicy = .CacheThenNetwork
		postsQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
			if let results = objects where error == nil {
				var postsDictionary = [String: [Post]]()
				for result in results {
					guard let post = result as? Post else { continue }
					
					// Key post groups by date
					let dateFormatter = NSDateFormatter()
					dateFormatter.dateFormat = "h:mm a"
					dateFormatter.timeZone = NSTimeZone(name: "PST")
					let key = dateFormatter.stringFromDate(post.deliveryTime)
					
					if postsDictionary[key] == nil {
						postsDictionary[key] = [Post]()
					}
					
					postsDictionary[key]?.append(post)
				}

				// Sort ascending by delivery time
				self.postsByTime = postsDictionary.map({ (key, value) -> [Post] in return value })
				self.postsByTime.sortInPlace({ (a, b) -> Bool in
					let aDate = a[0].deliveryTime
					let bDate = b[0].deliveryTime
					return aDate.compare(bDate) == .OrderedAscending
				})
				
				self.tableView.reloadData()
			}
		})
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
	}
	
	// MARK: - Collection View
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let hasMenuURL = self.restaurant.url.characters.count > 0
		switch section {
			case 0: return 2
			case 1: return hasMenuURL ? 2 : 1
			default: return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cellIdentifier = ""
		switch indexPath.section {
			case 0 where indexPath.row == 0: cellIdentifier = titleCellIdentifier
			case 0 where indexPath.row == 1: cellIdentifier = timesCellIdentifier
			case 1: cellIdentifier = normalCellIdentifier
			default: assert(cellIdentifier != "", "Invalid index path")
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		
		if let titleCell = cell as? RestaurantTitleCell {
			titleCell.restaurant = restaurant
			titleCell.selectionStyle = .None
		} else if let timesCell = cell as? RestaurantTimesCell {
			timesCell.delegate = self
			timesCell.posts = postsByTime
			timesCell.selectionStyle = .None
		} else {
			switch indexPath.row {
				case 0: cell.textLabel?.text = "Menu"
				default: cell.textLabel?.text = "View on Foursquare"
			}
			cell.accessoryType = .DisclosureIndicator
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
			case 0 where indexPath.row == 0: return titleCellHeight
			case 0 where indexPath.row == 1: return RestaurantTimesCell.heightForPostCount(postsByTime.count)
			case 1: return normalCellHeight
			default: return 0
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let hasMenuURL = self.restaurant.url.characters.count > 0
		let menuAction = {
			let safariViewController = SFSafariViewController(URL: NSURL(string: self.restaurant.url)!)
			self.presentViewController(safariViewController, animated: true, completion: nil)
		}
		let foursquareAction = {
			let foursquareURL = NSURL(string: self.restaurant.foursquareURL)!
			if UIApplication.sharedApplication().canOpenURL(NSURL(string: "foursquare://")!) {
				UIApplication.sharedApplication().openURL(foursquareURL)
			} else {
				let safariViewController = SFSafariViewController(URL: foursquareURL)
				self.presentViewController(safariViewController, animated: true, completion: nil)
			}
		}
		
		// Perform action
		switch indexPath.section {
			case 1 where indexPath.row == 0 && hasMenuURL == true: menuAction()
			case 1 where indexPath.row == 0 && hasMenuURL == false: foursquareAction()
			case 1 where indexPath.row == 1: foursquareAction()
			default: return
		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch (section) {
			case 1: return "More Info".uppercaseString
			default: return nil
		}
	}
	
	// MARK: - UIScrollViewDelegate
	func scrollViewDidScroll(scrollView: UIScrollView) {
		view.setNeedsLayout()
	}
	
	// MARK: - RestaurantHeaderViewDelegate
	func back() {
		navigationController!.popViewControllerAnimated(true)
	}
	
	// MARK: - DeliveryLocationCellDelegate
	func restaurantTimesCell(cell: RestaurantTimesCell, didSelectDate date: NSDate) {
		var posts = [Post]()
		for postGroup in postsByTime {
			if postGroup[0].deliveryTime.compare(date) == .OrderedSame {
				posts = postGroup
			}
		}
		
		let order = Order()
		
		let restaurantPointer = Location(withoutDataWithObjectId: restaurant.objectId)
		order.restaurant = restaurantPointer
		
		let orderViewController = OrderViewController()
		orderViewController.title = restaurant.name
		orderViewController.order = order
		orderViewController.posts = posts
		
		let orderNavigationController = UINavigationController(rootViewController: orderViewController)
		navigationController?.presentViewController(orderNavigationController, animated: true, completion: nil)
	}
	
	// MARK: - More	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
