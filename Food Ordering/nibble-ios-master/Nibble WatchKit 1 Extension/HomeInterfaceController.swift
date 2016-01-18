//
//  InterfaceController.swift
//  Nibble WatchKit 1 Extension
//
//  Created by Sachin on 11/22/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation
import Parse

class RestaurantCell: NSObject {
	@IBOutlet weak var detailLabel: WKInterfaceLabel!
	@IBOutlet weak var textLabel: WKInterfaceLabel!
}

class HomeInterfaceController: WKInterfaceController {
	@IBOutlet weak var tableView: WKInterfaceTable!
	var locations: [Location] = [Location]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
		User.registerSubclass()
		Location.registerSubclass()
		Order.registerSubclass()
		Post.registerSubclass()
		Photo.registerSubclass()
		Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.SachinPatel.Nibble", containingApplication: "com.SachinPatel.Nibble")
		Parse.setApplicationId("zFLGCSep1Jefdj9ZqCU69q59kKmiS9Tx9j33CCAI", clientKey: "NPzFgNF1LV5nXruwjmZRvGtp19rrrPqLLFboeync")
		
		PFCloud.callFunctionInBackground("validRestaurants", withParameters: nil, block: { (results, error) -> Void in
			if let venues = results as? [Location] {
				self.locations = venues
				self.tableView.setNumberOfRows(self.locations.count, withRowType: "RestaurantCell")
				for (index, location) in self.locations.enumerate() {
					if let cell = self.tableView.rowControllerAtIndex(index) as? RestaurantCell {
						cell.textLabel.setText(location.name)
						cell.detailLabel.setText("\(location.categoryString), \(location.priceTier)".uppercaseString)
					}
				}
			}
		})
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
	}
	
	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		let location = self.locations[rowIndex]
		pushControllerWithName("RestaurantInterfaceController", context: location)
	}

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
