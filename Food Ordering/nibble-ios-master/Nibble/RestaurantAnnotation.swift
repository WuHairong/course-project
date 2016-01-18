//
//  RestaurantAnnotation.swift
//  Nibble
//
//  Created by Sachin on 10/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
	var title: String?
	var subtitle: String?
	var coordinate: CLLocationCoordinate2D
	
	override init() {
		title = ""
		coordinate = CLLocationCoordinate2D()
		super.init()
	}
	
	convenience init(location: Location) {
		self.init()
		title = location.name
		coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
	}
}
