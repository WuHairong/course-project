//
//  RestaurantInterfaceController.swift
//  Nibble
//
//  Created by Sachin on 11/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation

class TimeCell: NSObject {
	@IBOutlet weak var textLabel: WKInterfaceLabel!
}

class RestaurantInterfaceController: WKInterfaceController {
	var restaurant: Location?
	var postsByTime: [[Post]] = [[Post]]()
	
	@IBOutlet var textLabel: WKInterfaceLabel!
	@IBOutlet var detailTextLabel: WKInterfaceLabel!
	@IBOutlet var tableView: WKInterfaceTable!
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
		self.restaurant = context as? Location
		textLabel.setText(self.restaurant?.name)
		detailTextLabel.setText("\(restaurant!.categoryString), \(restaurant!.priceTier)".uppercaseString)
		let postsQuery = restaurant?.posts.query()
		postsQuery?.includeKey("deliveryLocation")
		postsQuery?.cachePolicy = .CacheThenNetwork
		postsQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
			if let results = objects where error == nil {
				var postsDictionary = [String: [Post]]()
				for result in results {
					guard let post = result as? Post else { continue }
					
					// Key post groups by date
					let dateFormatter = NSDateFormatter()
					dateFormatter.dateFormat = "h:mm a"
					dateFormatter.timeZone = NSTimeZone(name: "PST")
					let key = dateFormatter.stringFromDate(post.deliveryTime)
					
					if postsDictionary[key] == nil {
						postsDictionary[key] = [Post]()
					}
					
					postsDictionary[key]?.append(post)
				}
				
				// Sort ascending by delivery time
				self.postsByTime = postsDictionary.map({ (key, value) -> [Post] in return value })
				self.postsByTime.sortInPlace({ (a, b) -> Bool in
					let aDate = a[0].deliveryTime
					let bDate = b[0].deliveryTime
					return aDate.compare(bDate) == .OrderedAscending
				})
				
				// Add cells
				self.tableView.setNumberOfRows(self.postsByTime.count, withRowType: "TimeCell")
				for (index, postGroup) in self.postsByTime.enumerate() {
					if let cell = self.tableView.rowControllerAtIndex(index) as? TimeCell {
						let time = postGroup[0].deliveryTime
						
						// Format date and set cell string
						let dateFormatter = NSDateFormatter()
						dateFormatter.dateFormat = "h:mm a"
						dateFormatter.timeZone = NSTimeZone(name: "PST")
						cell.textLabel.setText(dateFormatter.stringFromDate(time))
					}
				}
			}
		})
    }
	
	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		let posts = postsByTime[rowIndex]
		let dictionary = ["restaurant": restaurant!, "posts": posts]
		pushControllerWithName("DeliveryLocationsInterfaceController", context: dictionary)
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
