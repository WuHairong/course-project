//
//  Order.swift
//  Nibble
//
//  Created by Sachin on 10/16/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse

class Order: PFObject, PFSubclassing {
    
    // MARK: Custom Fields
	@NSManaged var user: User
	@NSManaged var driver: User
	@NSManaged var userRating: NSNumber
	@NSManaged var driverRating: NSNumber
	
	@NSManaged var text: String
	@NSManaged var deliveryTime: NSDate
	@NSManaged var restaurant: Location
	
	@NSManaged var assignedPost: Post
	@NSManaged var requestedPosts: PFRelation
	
	@NSManaged var pickedUp: Bool
	@NSManaged var delivered: Bool
	@NSManaged var cancelled: Bool
	
    // { get } from super class
    // objectID
    // createdAt
    // updatedAt
    // ACL
    
    // MARK: PFSubclassing Method
	class func parseClassName() -> String {
		return "Order"
	}
}
