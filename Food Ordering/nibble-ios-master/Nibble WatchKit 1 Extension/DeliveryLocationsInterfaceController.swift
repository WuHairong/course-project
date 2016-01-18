//
//  DeliveryLocationsInterfaceController.swift
//  Nibble
//
//  Created by Sachin on 11/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation

class DeliveryLocationCell: NSObject {
	@IBOutlet weak var textLabel: WKInterfaceLabel!
}

class DeliveryLocationsInterfaceController: WKInterfaceController {
	var restaurant: Location = Location()
	var posts: [Post] = [Post]()
	var deliveryLocations = [Location]()
	
	@IBOutlet var textLabel: WKInterfaceLabel!
	@IBOutlet var detailTextLabel: WKInterfaceLabel!
	@IBOutlet var tableView: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
		if let dictionary = context as? [String: AnyObject] {
			restaurant = (dictionary["restaurant"] as? Location)!
			posts = (dictionary["posts"] as? [Post])!
			
			textLabel.setText(restaurant.name)
			
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "h:mm a"
			dateFormatter.timeZone = NSTimeZone(name: "PST")
			detailTextLabel.setText(dateFormatter.stringFromDate(posts[0].deliveryTime))
			
			for post in posts {
				if deliveryLocations.contains(post.deliveryLocation) == false {
					deliveryLocations.append(post.deliveryLocation)
				}
			}
			
			tableView.setNumberOfRows(deliveryLocations.count, withRowType: "DeliveryLocationCell")
			for (index, deliveryLocation) in deliveryLocations.enumerate() {
				if let cell = tableView.rowControllerAtIndex(index) as? DeliveryLocationCell {
					cell.textLabel.setText(deliveryLocation.name)
				}
			}
		}
    }
	
	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		let post = posts[rowIndex]		
		presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain, completion: { (input) -> Void in
			guard let textInput = input else {
				return
			}
			if let text = textInput[0] as? String {
				let dictionary = ["restaurant": self.restaurant, "post": post, "text": text]
				self.pushControllerWithName("ConfirmationInterfaceController", context: dictionary)
			}
		})
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
