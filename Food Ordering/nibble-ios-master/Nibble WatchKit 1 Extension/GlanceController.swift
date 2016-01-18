//
//  GlanceController.swift
//  Nibble WatchKit 1 Extension
//
//  Created by Sachin on 11/22/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation
import Parse

class InfoCell: NSObject {
	@IBOutlet weak var detailLabel: WKInterfaceLabel!
	@IBOutlet weak var textLabel: WKInterfaceLabel!
}

class GlanceController: WKInterfaceController {
	var order: Order?
	@IBOutlet var statusLabel: WKInterfaceLabel!
	@IBOutlet var tableView: WKInterfaceTable!
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		
		User.registerSubclass()
		Location.registerSubclass()
		Order.registerSubclass()
		Post.registerSubclass()
		Photo.registerSubclass()
		Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.SachinPatel.Nibble", containingApplication: "com.SachinPatel.Nibble")
		Parse.setApplicationId("zFLGCSep1Jefdj9ZqCU69q59kKmiS9Tx9j33CCAI", clientKey: "NPzFgNF1LV5nXruwjmZRvGtp19rrrPqLLFboeync")
		
		tableView.setNumberOfRows(3, withRowType: "InfoCell")
		
		// Load from Parse
		let ordersQuery = User.currentUser()?.orders.query()
		ordersQuery?.includeKey("restaurant")
		ordersQuery?.includeKey("assignedPost")
		ordersQuery?.includeKey("assignedPost.deliveryLocation")
		ordersQuery?.orderByDescending("updatedAt")
		ordersQuery?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
			if error == nil {
				if let order = object as? Order {
					self.order = order
					self.refresh()
				}
			}
		})
    }
	
	func refresh() {
		if let currentOrder = order {
			var statusText = "Pending"
			if currentOrder.pickedUp == true {
				statusText = "Picked Up"
			} else if currentOrder.delivered == true {
				statusText = "Delivered"
			}
			statusLabel.setText(statusText)
			
			if let fromCell = tableView.rowControllerAtIndex(0) as? InfoCell {
				fromCell.detailLabel.setText("From".uppercaseString)
				fromCell.textLabel.setText(currentOrder.restaurant.name)
			}
			
			if let toCell = tableView.rowControllerAtIndex(1) as? InfoCell {
				toCell.detailLabel.setText("To".uppercaseString)
				
				if currentOrder.assignedPost.deliveryLocation.name.characters.count > 0 {
					toCell.textLabel.setText(currentOrder.assignedPost.deliveryLocation.name)
					
					if let atCell = tableView.rowControllerAtIndex(2) as? InfoCell {
						atCell.detailLabel.setText("At".uppercaseString)
						
						let formatter = NSDateFormatter()
						formatter.dateFormat = "h:mm a"
						formatter.timeZone = NSTimeZone(name: "PST")
						atCell.textLabel.setText(formatter.stringFromDate(currentOrder.assignedPost.deliveryTime))
					}
				} else {
					toCell.textLabel.setText("Pending")
				}
			}
		}
	}

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
