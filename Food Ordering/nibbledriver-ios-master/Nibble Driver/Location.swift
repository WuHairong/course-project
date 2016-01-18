//
//  Location.swift
//  Nibble
//
//  Created by Sachin on 10/16/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse

class Location: PFObject, PFSubclassing {
    
    // MARK: Custom Fields
	@NSManaged var name: String
	@NSManaged var coordinate: PFGeoPoint
	@NSManaged var foursquareID: String
	
	@NSManaged var foursquareURL: String
	@NSManaged var thumbnailURL: String
	
    @NSManaged var rating: NSNumber
	@NSManaged var priceTier: String
	@NSManaged var categories: [String]
	
	@NSManaged var posts: PFRelation
	@NSManaged var photos: PFRelation
	
    @NSManaged var url: String
	
	var address: String?
	
	var categoryString: String {
		get {
			var returnValue = ""
			for component in categories {
				returnValue += "\(component), "
			}
			if returnValue.characters.count > 3 {
				// Trim ", " from end
				returnValue = returnValue.substringToIndex(returnValue.endIndex.predecessor().predecessor())
			}
			return returnValue
		}
	}
    
    // { get } from super class
    // objectID
    // createdAt
    // updatedAt
    // ACL

    
	// MARK: PFSubclassing Method
	class func parseClassName() -> String {
		return "Location"
	}
}
