//
//  User.swift
//  Nibble
//
//  Created by Sachin on 10/24/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import Foundation
import Parse

class User: PFUser {
	
	// MARK: Custom Fields
	@NSManaged var firstName: String
	@NSManaged var lastName: String
	@NSManaged var orders: PFRelation
	@NSManaged var posts: PFRelation
	@NSManaged var profilePictureURL: String
	@NSManaged var profilePicture: PFFile
	@NSManaged var appInstallation: PFObject
	@NSManaged var driverAppInstallation: PFObject
	
	// { get } from super class
	// objectID
	// createdAt
	// updatedAt
	// ACL
}
