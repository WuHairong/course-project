//
//  HistoryViewController.swift
//  Nibble
//
//  Created by Varun Arora on 10/26/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    let cellIdentifier = "HistoryCell"
	let cellHeight = CGFloat(105)
    var orders: [Order]
    
    // MARK: UI
    var tableView: UITableView

    // MARK: Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        orders = [Order]()
        tableView = UITableView(frame: CGRectZero, style: .Plain)
		
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.appBackgroundColor()
        tableView.registerClass(HistoryCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
        view.backgroundColor = UIColor.appBackgroundColor()
		
        title = "My Orders"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
		
		// Refresh when coming from background
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table View
		let tableViewFrame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        if !CGRectEqualToRect(tableView.frame, tableViewFrame) {
            tableView.frame = tableViewFrame
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		refresh()
    }
	
	func refresh() {
		guard let currentUser = User.currentUser() else { return }
		guard let userOrdersQuery = currentUser.orders.query() else { return }
		userOrdersQuery.orderByDescending("createdAt")
		userOrdersQuery.includeKey("restaurant")
		userOrdersQuery.includeKey("driver")
        userOrdersQuery.includeKey("assignedPost.deliveryLocation")
		userOrdersQuery.cachePolicy = .CacheThenNetwork
		userOrdersQuery.findObjectsInBackgroundWithBlock({(objects, error) -> () in
			if let orders = objects as? [Order] {
				self.orders = orders
				self.tableView.reloadData()
			}
		})
	}
	
    // MARK: UITableViewDataSource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return orders.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? HistoryCell else { return UITableViewCell() }
		cell.order = orders[indexPath.row]
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return cellHeight
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let historyDetailViewController = HistoryDetailViewController(order: orders[indexPath.row])
		navigationController?.pushViewController(historyDetailViewController, animated: true)
	}
	
    // MARK: More
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}