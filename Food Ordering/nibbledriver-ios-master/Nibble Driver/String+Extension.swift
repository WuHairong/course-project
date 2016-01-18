//
//  String+Extension.swift
//  Nibble Driver
//
//  Created by Sachin on 11/22/15.
//  Copyright © 2015 Nibble. All rights reserved.
//

import Foundation

extension String {
	var urlEncoded: String {
		get {
			return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
		}
	}
}