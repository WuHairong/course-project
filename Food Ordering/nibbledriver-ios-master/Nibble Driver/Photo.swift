//
//  Photo.swift
//  Nibble
//
//  Created by Varun Arora on 10/23/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse

class Photo: PFObject, PFSubclassing {
    
    // MARK: Custom Fields
	@NSManaged var foursquareID: String
    @NSManaged var urlPrefix: String
    @NSManaged var urlSuffix: String
    @NSManaged var width: NSNumber
	@NSManaged var height: NSNumber
    
    // { get } from super class
    // objectID
    // createdAt
    // updatedAt
    // ACL
    
    // MARK: PFSubclassing Method
    class func parseClassName() -> String {
        return "Photo"
    }
	
	func url() -> NSURL {
		let url = "\(urlPrefix)\(width)x\(height)\(urlSuffix)"
		return NSURL(string: url)!
	}
}
