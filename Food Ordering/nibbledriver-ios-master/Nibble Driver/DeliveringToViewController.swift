//
//  DeliveringToViewController.swift
//  Nibble Driver
//
//  Created by Sachin on 10/26/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import UIKit

class DeliveringToViewController: LocationPickerViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Delivering To"
		navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
		
		let deliveringAtViewController = DeliveringAtViewController()
		if self.context != nil {
			var deliveringAtContext = self.context!
			deliveringAtContext["deliveringTo"] = locations[indexPath.row]
			deliveringAtViewController.context = deliveringAtContext
		}
		self.navigationController?.pushViewController(deliveringAtViewController, animated: true)
	}
}
