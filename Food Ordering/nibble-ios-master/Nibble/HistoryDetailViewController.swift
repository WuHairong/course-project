//
//  HistoryDetailViewController.swift
//  Nibble
//
//  Created by Varun Arora on 11/5/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse

class HistoryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RestaurantHeaderViewDelegate {
	enum MapType {
		case Restaurant
		case DeliveryLocation
	}
	
    // MARK: Properties
    var order: Order
    let driverIdentifier = "driverCell"
    let locationIdentifier = "locationIdentifier"
    let statusIdentifier = "statusCell"
    let infoIdentifier = "infoCell"
	
	let headerHeight = CGFloat(150)
	let topInteractiveHeight = CGFloat(80)
	
    // MARK: UI
    var tableView: UITableView
    var headerView: RestaurantHeaderView
    
    // MARK: - Initialization
	convenience init(order: Order) {
		self.init(nibName: nil, bundle: nil)
		
		self.order = order
		commonInit()
	}
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        order = Order()
        headerView = RestaurantHeaderView();
		
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		
		headerView.restaurant = order.restaurant
		headerView.delegate = self
		view.addSubview(headerView)
		
        tableView.dataSource = self
        tableView.delegate = self
		tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
		tableView.showsVerticalScrollIndicator = false
        tableView.registerClass(HistoryDetailDriverCell.self, forCellReuseIdentifier: driverIdentifier)
        tableView.registerClass(HistoryDetailLocationCell.self, forCellReuseIdentifier: locationIdentifier)
        tableView.registerClass(HistoryDetailStatusCell.self, forCellReuseIdentifier: statusIdentifier)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: infoIdentifier)
        tableView.backgroundColor = UIColor.clearColor()
		tableView.contentInset = UIEdgeInsetsMake(headerHeight - topInteractiveHeight, 0, 0, 0)
        view.addSubview(tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.appBackgroundColor()
        
        // Refresh when coming from background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
		let calculatedHeaderHeight = max(headerHeight - tableView.contentOffset.y, topInteractiveHeight)
		headerView.frame = CGRectMake(0, 0, view.frame.width, calculatedHeaderHeight)
		tableView.frame = CGRectMake(0, topInteractiveHeight, view.frame.width, view.frame.height - topInteractiveHeight)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        tableView.reloadData()
    }
    
    // MARK: - UITableView
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch (section) {
			case 0: return 3
			case 1 where order.delivered: return 3 // Delivered + Out for delivery + Order placed
            case 1 where order.pickedUp: return 2 // Out for delivery + Order placed
			case 1 where order.cancelled: return 1 // Cancelled status
            case 1: return 1 // Order placed
			case 2 where order.driver.username?.characters.count > 0: return 1
            case 2 where order.cancelled: return 1
            case 2: return 2
			default: return 0
		}
	}
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cellIdentifier = ""
		switch indexPath.section {
			case 0 where indexPath.row == 0: cellIdentifier = driverIdentifier
			case 0 where indexPath.row != 0: cellIdentifier = locationIdentifier
			case 1: cellIdentifier = statusIdentifier
			case 2: cellIdentifier = infoIdentifier
			default: return UITableViewCell()
		}

		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		if let driverCell = cell as? HistoryDetailDriverCell {
            driverCell.driver = self.order.driver
            driverCell.selectionStyle = .None
            return driverCell
			
		} else if let locationCell = cell as? HistoryDetailLocationCell {
            if indexPath.row == 1 {
				locationCell.locationTitle = "\(order.delivered ? "Delivered" : "Delivering") from"
                locationCell.location = self.order.restaurant
                
            } else if indexPath.row == 2 {
                locationCell.cancelled = order.cancelled
                locationCell.location = order.assignedPost.deliveryLocation
				locationCell.locationTitle = "\(order.delivered ? "Delivered" : "Delivering") to"
            }
			return locationCell
		} else if let statusCell = cell as? HistoryDetailStatusCell {
            statusCell.selectionStyle = .None
            switch indexPath.row {
                case 0 where order.cancelled:
                    statusCell.statusText = "Cancelled"
                case 0 where order.delivered:
                    statusCell.statusText = "Delivered"
                case 0 where order.pickedUp:
                    statusCell.statusText = "Out for delivery"
                case 0:
                    statusCell.statusText = "Order placed"
                case 1 where order.delivered:
                    statusCell.statusText = "Out for delivery"
                case 1 where order.pickedUp:
                    statusCell.statusText = "Order placed"
                case 2 where order.delivered:
                    statusCell.statusText = "Order placed"
                default:
					statusCell.statusText = "Error"
            }
			return statusCell
			
		} else if cellIdentifier == infoIdentifier {
			cell.textLabel?.font = UIFont.appFontOfSize(16.0, weight: .Regular)
			if indexPath.row == 0 {
				cell.textLabel?.text = "Contact Us"
			} else if indexPath.row == 1 {
				cell.textLabel?.text = "Cancel Order"
				cell.textLabel?.textColor = UIColor.redColor()
			}
		}
		
		return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
			case 1: return "Status".uppercaseString
			case 2: return "More Info".uppercaseString
			default: return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section) {
            case 0 where indexPath.row == 0: return 75
            case 0: return 85
            case 1: return 70
            case 2: return 55
            default: return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
			case 0 where indexPath.row == 1: openMap(.Restaurant)
			case 0 where indexPath.row == 2: openMap(.DeliveryLocation)
            case 2 where indexPath.row == 1: confirmCancel()
            case 2 where indexPath.row == 0: goToMail()
            default: return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
	
	// MARK: - UIScrollViewDelegate
	func scrollViewDidScroll(scrollView: UIScrollView) {
		view.setNeedsLayout()
	}
	
	// MARK: - RestaurantHeaderViewDelegate
	func back() {
		navigationController?.popViewControllerAnimated(true)
	}
	
	// MARK: - More
	func cancelOrder() {
		self.order.cancelled = true
		self.order.saveInBackgroundWithBlock({(succeeded, error) -> () in
			if (succeeded) {
				self.cancelComplete()
				self.tableView.reloadData()
			} else {
				// #programming
				NSLog("CGRekt")
			}
		})
	}
	
	func confirmCancel() {
		let alert = UIAlertController(title: "Cancel Order?", message: nil, preferredStyle: .ActionSheet)
		alert.addAction(UIAlertAction(title: "Cancel Order", style: .Destructive, handler: { (alert: UIAlertAction) in
			self.cancelOrder()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func cancelComplete() {
		let alert = UIAlertController(title: "Order Cancelled", message: "", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func goToMail() {
		let emailURL = NSURL(string: "mailto:me@gizmosachin.com?subject=Nibble%20User%20Inquiry")
		UIApplication.sharedApplication().openURL(emailURL!)
	}
	
	func openMap(locationType: MapType) {
		var urlString = "http://maps.apple.com"
		switch (locationType) {
		case .Restaurant:
			let latitude = order.restaurant.coordinate.latitude
			let longitude = order.restaurant.coordinate.longitude
			urlString = "http://maps.apple.com/?q=\(latitude),\(longitude)&ll=\(latitude),\(longitude)&spn=.001,.001"
			
		case .DeliveryLocation where (order.cancelled != true && order.driver.username?.characters.count > 0):
			let latitude = order.assignedPost.deliveryLocation.coordinate.latitude
			let longitude = order.assignedPost.deliveryLocation.coordinate.longitude
			urlString = "http://maps.apple.com/?q=\(latitude),\(longitude)&ll=\(latitude),\(longitude)&spn=.001,.001"
		default: return
		}
		UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
