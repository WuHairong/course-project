//
//  NibbleParse.swift
//  Nibble Driver
//
//  Created by Sachin on 11/1/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import Foundation
import Parse

class NibbleParse {
	class func pointerFromDuplicateError(error: NSError, attemptedObject: PFSubclassing) -> PFObject? {
		do {
			guard let data = error.localizedDescription.dataUsingEncoding(NSUTF8StringEncoding) else {
				print("Couldn't convert string to data.")
				return nil
			}
			let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
			if let objectId = JSON["objectId"] as? String {
				return PFObject(withoutDataWithClassName: attemptedObject.dynamicType.parseClassName(), objectId: objectId)
			}
		} catch {
			print("Couldn't parse JSON.")
			return nil
		}
		return nil
	}
}