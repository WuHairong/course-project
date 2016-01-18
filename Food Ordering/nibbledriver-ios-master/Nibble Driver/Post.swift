//
//  Post.swift
//  Nibble
//
//  Created by Varun Arora on 10/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse


class Post: PFObject, PFSubclassing {
    
    // MARK: Custom Fields
    @NSManaged var active: Bool
    @NSManaged var deliveryLocation: Location
    @NSManaged var deliveryTime: NSDate
    @NSManaged var driver: User
	
    @NSManaged var pendingOrders: PFRelation
	@NSManaged var acceptedOrders: PFRelation
	
    @NSManaged var restaurant: Location
    
    
    // { get } from super class
    // objectID
    // createdAt
    // updatedAt
    // ACL
    
    
    // MARK: PFSubclassing Method
    class func parseClassName() -> String {
        return "Post"
    }
}