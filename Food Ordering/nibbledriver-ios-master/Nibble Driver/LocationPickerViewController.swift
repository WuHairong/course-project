//
//  LocationPickerViewController.swift
//  Nibble Driver
//
//  Created by Sachin on 10/24/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

class LocationPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	let cellIdentifier = "LocationPickerCell"
	var context: [String: AnyObject]?
	
	var categoryId: String?
	var textFieldBackground: UIView
	var textField: UITextField
	var separatorLine: UIView
	var tableView: UITableView
	var locations: [Location]
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		textFieldBackground = UIView()
		textField = UITextField()
		separatorLine = UIView()
		tableView = UITableView()
		locations = [Location]()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		
		textFieldBackground.backgroundColor = UIColor.whiteColor()
		view.addSubview(textFieldBackground)
		
		textField.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
		textField.font = UIFont.appFontOfSize(20, weight: .Regular)
		view.addSubview(textField)
		
		separatorLine.backgroundColor = UIColor.appTintColor()
		view.addSubview(separatorLine)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UIColor.appBackgroundColor()
		tableView.rowHeight = 80
		tableView.registerClass(LocationPickerCell.self, forCellReuseIdentifier: cellIdentifier)
		view.addSubview(tableView)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(animated: Bool) {
		textFieldDidChange()
	}
	
	override func viewDidAppear(animated: Bool) {
		textField.becomeFirstResponder()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		textFieldBackground.frame = CGRectMake(0, 0, view.frame.width, 64.0)
		textField.frame = CGRectMake(15.0, 0.0, view.frame.width - 15.0 * 2.0, textFieldBackground.frame.height - 5.0 * 2.0)
		separatorLine.frame = CGRectMake(0, textField.frame.maxY, view.frame.width, 1.0 / UIScreen.mainScreen().scale)
		tableView.frame = CGRectMake(0.0, separatorLine.frame.maxY, view.frame.width, view.frame.height - separatorLine.frame.maxY)
	}

	// MARK: Table View
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
	}
	
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let newCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? LocationPickerCell {
			newCell.location = locations[indexPath.row]
			return newCell
		}
        return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		textField.resignFirstResponder()
		// Subclasses should override this method
	}
	
	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		textField.resignFirstResponder()
	}
	
	// MARK: More
	func textFieldDidChange() {
		CurrentLocation.sharedInstance.get { (location) -> () in
			if let query = self.textField.text {
				var category = ""
				if self.categoryId != nil {
					category += self.categoryId!
				}
				Foursquare.getVenues(query, categoryId:category, location: location) { (locations, error) -> () in
					self.locations = locations
					self.tableView.reloadData()
				}
			}
		}
	}
}
