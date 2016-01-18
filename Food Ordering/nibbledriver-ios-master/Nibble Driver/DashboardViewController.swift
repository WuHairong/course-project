//
//  DashboardViewController.swift
//  Nibble
//
//  Created by Sachin on 10/4/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

import Parse
import AHKNavigationController

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OrderCellDelegate, DashboardStatusViewDelegate {
	let cellPadding = CGFloat(20)
	let emptyViewIdentifier = "UICollectionReusableView"
	let statusViewIdentifier = "DashboardStatusView"
	let cellIdentifier = "OrderCell"
	
	// UI
	var collectionView: UICollectionView
	
	// Data Source
	var post: Post?
	var pendingOrders: [Order]
	var acceptedOrders: [Order]
	
	// MARK: Init
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.minimumInteritemSpacing = cellPadding
		collectionViewLayout.minimumLineSpacing = cellPadding
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
		
		pendingOrders = [Order]()
		acceptedOrders = [Order]()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {		
		view.backgroundColor = UIColor.appBackgroundColor()
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.backgroundColor = UIColor.clearColor()
		collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: emptyViewIdentifier)
		collectionView.registerClass(DashboardStatusView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: statusViewIdentifier)
		collectionView.registerClass(OrderCell.self, forCellWithReuseIdentifier: cellIdentifier)
		view.addSubview(collectionView)
	}
	
	// MARK: View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Refresh when coming from background
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
		
		// Refresh when creating posts
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "RefreshDashboard", object: nil)
		
		title = "Dashboard"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Collection view
		let collectionViewFrame = CGRectMake(0, 0, view.frame.width, view.frame.height)
		if !CGRectEqualToRect(collectionView.frame, collectionViewFrame) {
			collectionView.frame = collectionViewFrame
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		refresh()
		
		CurrentLocation.sharedInstance.requestAuthorization { (authorized) -> () in
			if !authorized {
				print("Unauthorized :(")
			}
		}
		
		// Show login page if necessary
		if PFUser.currentUser() == nil {
			let landingViewController = LandingViewController()
			let landingNavigationController = AHKNavigationController(rootViewController: landingViewController)
			landingNavigationController.setNavigationBarHidden(true, animated: false)
			presentViewController(landingNavigationController, animated: false, completion: nil)
		}
	}
	
	func refresh() {
		let postsQuery = User.currentUser()?.posts.query()
		postsQuery?.includeKey("restaurant")
		postsQuery?.includeKey("deliveryLocation")
		postsQuery?.limit = 1
		postsQuery?.orderByDescending("createdAt")
		postsQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
			if error == nil {
				if let post = objects?[0] as? Post {
					self.post = post
					
					// Pending orders
					let pendingOrdersQuery = self.post?.pendingOrders.query()
					pendingOrdersQuery?.orderByDescending("updatedAt")
					pendingOrdersQuery?.includeKey("user")
					pendingOrdersQuery?.findObjectsInBackgroundWithBlock({ (orders, error) -> Void in
						if error == nil {
							if let pendingOrders = orders as? [Order] {
								self.pendingOrders = pendingOrders
								self.collectionView.reloadSections(NSIndexSet(index: 0))
							}
						}
					})
					
					// Acccepted orders
					let acceptedOrdersQuery = self.post?.acceptedOrders.query()
					acceptedOrdersQuery?.orderByDescending("updatedAt")
					acceptedOrdersQuery?.includeKey("user")
					acceptedOrdersQuery?.findObjectsInBackgroundWithBlock({ (orders, error) -> Void in
						if error == nil {
							if let acceptedOrders = orders as? [Order] {
								self.acceptedOrders = acceptedOrders
								self.sortAcceptedOrdersAndRefresh()
							}
						}
					})
				} else {
					// New driver, no posts
				}
			}
		})
	}
	
	// MARK: - Collection View
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		// Pending + Accepted orders
		return 2
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
			case 0: return pendingOrders.count
			case 1: return acceptedOrders.count
			default: return 0
		}
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if let newCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? OrderCell {
			newCell.order = orderForIndexPath(indexPath)
			newCell.delegate = self
			return newCell
		}
		return UICollectionViewCell()
	}
	
	func orderForIndexPath(indexPath: NSIndexPath) -> Order {
		switch indexPath.section {
			case 0: return pendingOrders[indexPath.row]
			case 1: return acceptedOrders[indexPath.row]
			default: return Order()
		}
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let cellHeight = OrderCell.cellHeightForOrder(orderForIndexPath(indexPath), width: view.frame.width)
		return CGSizeMake(view.frame.width, cellHeight)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		var topPadding = cellPadding
		if section == 0 && pendingOrders.count == 0 {
			topPadding = 0
		} else if section == 1 && acceptedOrders.count == 0 {
			topPadding = 0
		}
		return UIEdgeInsetsMake(topPadding, 0, cellPadding, 0)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if section == 0 {
			return CGSizeMake(view.frame.width, DashboardStatusView.heightForPost(self.post))
		}
		return CGSizeZero
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		if let statusView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: statusViewIdentifier, forIndexPath: indexPath) as? DashboardStatusView where indexPath.section == 0 {
			if let currentPost = post {
				statusView.post = currentPost
			}
			statusView.delegate = self
			return statusView
		}
		return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: emptyViewIdentifier, forIndexPath: indexPath)
	}
	
	// MARK: - OrderCellDelegate
	func orderCell(cell: OrderCell, didIgnoreOrder order: Order) {
		if let index = pendingOrders.indexOf(order) {
			pendingOrders.removeAtIndex(index)
			collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
		}
		PFCloud.callFunctionInBackground("rejectOrder", withParameters: ["objectId": order.objectId!]) { (result, error) -> Void in
			if error != nil {
				print(error?.localizedDescription)
			}
		}
	}
	
	func orderCell(cell: OrderCell, didAcceptOrder order: Order) {
		let index = pendingOrders.indexOf(order)!
		
		// Moving from current position to top of acceptedOrders, since both are sorted by updatedAt
		order.assignedPost = post!
		let startingIndexPath = NSIndexPath(forItem: index, inSection: 0)
		let endingIndexPath = NSIndexPath(forItem: 0, inSection: 1)
		pendingOrders.removeAtIndex(index)
		acceptedOrders.insert(order, atIndex: 0)
		collectionView.moveItemAtIndexPath(startingIndexPath, toIndexPath: endingIndexPath)
		
		PFCloud.callFunctionInBackground("acceptOrder", withParameters: ["objectId": order.objectId!]) { (result, error) -> Void in
			if error != nil {
				print(error?.localizedDescription)
			}
		}
	}
	
	func orderCell(cell: OrderCell, didPickUpOrder order: Order) {
		if cell.deliveredItem.checked != true {
			cell.pickedUpItem.checked = !cell.pickedUpItem.checked
			order.pickedUp = true
			order.saveInBackground()
			
			sortAcceptedOrdersAndRefresh()
		}
	}
	
	func orderCell(cell: OrderCell, didDeliverOrder order: Order) {
		if cell.pickedUpItem.checked == true && cell.deliveredItem.checked != true {
			let alertController = UIAlertController(title: nil, message: "Please confirm that this order was delivered. If there's a problem, contact us. There is no undo.", preferredStyle: .ActionSheet)
			alertController.addAction(UIAlertAction(title: "Mark as Delivered", style: .Default, handler: { (action) -> Void in
				cell.deliveredItem.checked = true
				order.delivered = true
				order.saveInBackground()
				
				self.sortAcceptedOrdersAndRefresh()
			}))
			alertController.addAction(UIAlertAction(title: "Contact Us", style: .Default, handler: { (action) -> Void in
				let url = "mailto:sabhpate@ucsc.edu?subject=Driver%20Problem%20with%20Order%20\(order.objectId!)".urlEncoded
				UIApplication.sharedApplication().openURL(NSURL(string: url)!)
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			presentViewController(alertController, animated: true, completion: nil)
		}
	}
	
	// MARK: - DashboardStatusViewDelegate
	func dashboardStatusViewTapped(statusView: DashboardStatusView) {
		if post != nil && post!.active == true {
			let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
			alertController.addAction(UIAlertAction(title: "Restaurant Info", style: .Default, handler: { (action) -> Void in
				let foursquareURL = NSURL(string: (self.post?.restaurant.foursquareURL)!)!
				if UIApplication.sharedApplication().canOpenURL(NSURL(string: "foursquare://")!) {
					UIApplication.sharedApplication().openURL(foursquareURL)
				} else {
					let safariViewController = SFSafariViewController(URL: foursquareURL)
					self.presentViewController(safariViewController, animated: true, completion: nil)
				}
			}))
			alertController.addAction(UIAlertAction(title: "Directions to Restaurant", style: .Default, handler: { (action) -> Void in
				guard let latitude = self.post?.restaurant.coordinate.latitude else { return }
				guard let longitude = self.post?.restaurant.coordinate.longitude else { return }
				let mapsURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d"
				UIApplication.sharedApplication().openURL(NSURL(string: mapsURL)!)
			}))
			alertController.addAction(UIAlertAction(title: "Directions to Pickup Location", style: .Default, handler: { (action) -> Void in
				guard let latitude = self.post?.deliveryLocation.coordinate.latitude else { return }
				guard let longitude = self.post?.deliveryLocation.coordinate.longitude else { return }
				let mapsURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d"
				UIApplication.sharedApplication().openURL(NSURL(string: mapsURL)!)
			}))
			alertController.addAction(UIAlertAction(title: "Go Offline", style: .Destructive, handler: { (action) -> Void in
				let innerAlertController = UIAlertController(title: nil, message: "Are you sure you want to go offline? You still must deliver any orders that you've accepted.", preferredStyle: .ActionSheet)
				innerAlertController.addAction(UIAlertAction(title: "Go Offline", style: .Destructive, handler: { (action) -> Void in
					self.post!.active = false
					self.post!.saveInBackgroundWithBlock({ (success, error) -> Void in
						self.refresh()
					})
				}))
				innerAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				self.presentViewController(innerAlertController, animated: true, completion: nil)
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			presentViewController(alertController, animated: true, completion: nil)
		} else {
			let newTripViewController = DeliveringFromViewController()
			let navigationController = UINavigationController(rootViewController: newTripViewController)
			presentViewController(navigationController, animated: true, completion: nil)
		}
	}
	
	// MARK: - More
	func sortAcceptedOrdersAndRefresh() {
		acceptedOrders.sortInPlace { (order1, order2) -> Bool in
			let order1Score = (order1.pickedUp == false ? 1 : 0) + (order1.delivered == false ? 1 : 0)
			let order2Score = (order2.pickedUp == false ? 1 : 0) + (order2.delivered == false ? 1 : 0)
			return order1Score > order2Score
		}
		self.collectionView.reloadSections(NSIndexSet(index: 1))
	}
	
	func showNewTrip() {
		let newTripViewController = DeliveringFromViewController()
		let navigationController = UINavigationController(rootViewController: newTripViewController)
		presentViewController(navigationController, animated: true, completion: nil)
	}
}
