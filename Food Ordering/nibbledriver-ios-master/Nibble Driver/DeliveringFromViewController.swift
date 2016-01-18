//
//  DeliveringFromViewController.swift
//  Nibble Driver
//
//  Created by Sachin on 10/26/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

class DeliveringFromViewController: LocationPickerViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Delivering From"
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "cancel")
		navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
		
		// Foursquare's category ID for food
		categoryId = "4d4b7105d754a06374d81259"
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
				
		let deliveringToViewController = DeliveringToViewController()
		deliveringToViewController.context = ["deliveringFrom": locations[indexPath.row]]
		self.navigationController?.pushViewController(deliveringToViewController, animated: true)
	}
	
	func cancel() {
		dismissViewControllerAnimated(true, completion: nil)
	}
}
