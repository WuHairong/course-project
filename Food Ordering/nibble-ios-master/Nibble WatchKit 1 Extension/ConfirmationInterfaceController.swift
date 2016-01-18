//
//  ConfirmationInterfaceController.swift
//  Nibble
//
//  Created by Sachin on 11/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation
import Parse

class ConfirmationInterfaceController: WKInterfaceController {
	var restaurant: Location = Location()
	var post = Post()
	var text = ""
	var deliveryLocations = [Location]()
	
	@IBOutlet var textLabel: WKInterfaceLabel!
	@IBOutlet var detailTextLabel: WKInterfaceLabel!
	@IBOutlet var secondDetailTextLabel: WKInterfaceLabel!
	@IBOutlet var thirdDetailTextLabel: WKInterfaceLabel!
	@IBOutlet var button: WKInterfaceButton!
	
	override func awakeWithContext(context: AnyObject?) {
		super.awakeWithContext(context)
		
		// Configure interface objects here.
		if let dictionary = context as? [String: AnyObject] {
			restaurant = dictionary["restaurant"] as! Location
			post = (dictionary["post"] as! Post)
			text = (dictionary["text"] as! String)
			
			textLabel.setText(restaurant.name)
			
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "h:mm a"
			dateFormatter.timeZone = NSTimeZone(name: "PST")
			detailTextLabel.setText(dateFormatter.stringFromDate(post.deliveryTime))
			
			secondDetailTextLabel.setText(post.deliveryLocation.name)
			thirdDetailTextLabel.setText(text)
		}
	}
	
	@IBAction func placeOrder() {
		let order = Order()
		
		let restaurantPointer = Location(withoutDataWithObjectId: restaurant.objectId)
		order.restaurant = restaurantPointer
		order.requestedPosts.addObject(post)
		order.text = text
		
		button.setTitle("Loading...")
		
		let sharedDefaults = NSUserDefaults(suiteName: "group.com.SachinPatel.Nibble")
		sharedDefaults?.synchronize()
		
		guard let userId = sharedDefaults?.valueForKey("userId") as? String else {
			button.setTitle("Error")
			return
		}
		
		let userPointer = User(withoutDataWithObjectId: userId)
		order.user = userPointer
		order.saveInBackgroundWithBlock({ (success, error) -> Void in
			if (error == nil) {
				self.pushControllerWithName("ConfirmedInterfaceController", context: nil)
			} else {
				self.button.setTitle("Error")
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
