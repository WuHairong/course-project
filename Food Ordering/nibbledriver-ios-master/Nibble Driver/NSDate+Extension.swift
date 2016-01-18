//
//  NSDate+DHAdditions.swift
//  UCSC Dining
//
//  Created by Sachin on 9/28/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import Foundation

extension NSDate {
	var components: NSDateComponents {
		return NSCalendar.currentCalendar().components([.Era, .Month, .Day, .Year, .Hour, .Minute, .Weekday], fromDate: self)
	}

	var dateString: String {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "M/d/yy"
		
		let dateString = formatter.stringFromDate(self)
		let todayString = formatter.stringFromDate(NSDate())
		
		return dateString == todayString ? "Today" : dateString
	}
	
	var timeString: String {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "h:mm a"
		return formatter.stringFromDate(self)
	}
	
	var hour: Int {
		get {
			return self.components.hour
		}
	}
	
	var minute: Int {
		get {
			return self.components.minute
		}
	}
	
	class func withHours(h: Int, m: Int, PM: Bool) -> NSDate {
		let calendar = NSCalendar.autoupdatingCurrentCalendar()
		let components = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
		components.hour = h + (PM ? 12 : 0)
		components.minute = m
		return calendar.dateFromComponents(components)!
	}
}