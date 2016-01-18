//
//  CurrentLocation.swift
//  Nibble
//
//  Created by Sachin on 10/15/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocation: NSObject, CLLocationManagerDelegate {
	class var authorized: Bool {
		get {
			let status = CLLocationManager.authorizationStatus()
			return status == .AuthorizedWhenInUse || status == .AuthorizedAlways
		}
	}
	
	class var sharedInstance: CurrentLocation {
		struct Static {
			static var onceToken : dispatch_once_t = 0
			static var instance : CurrentLocation? = nil
		}
		
		dispatch_once(&Static.onceToken) {
			Static.instance = CurrentLocation()
		}
		
		return Static.instance!
	}
	
	// Local variables
	var lastLocation: CLLocation?
	private let manager: CLLocationManager
	private var authorizationStatusBlock: ((Bool) -> ())
	private var locationUpdateBlock: ((CLLocation) -> ())
	
	override init() {
		manager = CLLocationManager()
		authorizationStatusBlock = { authorized in }
		locationUpdateBlock = { location in }
		
		super.init()
		manager.delegate = self
	}
	
	func requestAuthorization(completion: (Bool) -> ()) {
		if CurrentLocation.authorized == true {
			completion(true)
			return
		}
		authorizationStatusBlock = completion
		manager.requestWhenInUseAuthorization()
	}
	
	func get(completion: (CLLocation) -> ()) {
		if CurrentLocation.authorized == false {
			let alertController = UIAlertController(
				title: "Location Disabled",
				message: "In order to be use Nibble, please open settings and set location access to 'When In Use'.",
				preferredStyle: .Alert)
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
			alertController.addAction(cancelAction)
			
			let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
				if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
					UIApplication.sharedApplication().openURL(url)
				}
			}
			alertController.addAction(openAction)
			
			let keyWindow = UIApplication.sharedApplication().keyWindow
			if let topViewController = keyWindow?.rootViewController {
				topViewController.presentViewController(alertController, animated: true, completion: nil)
			}
			return
		}
		
		if lastLocation != nil {
			completion(lastLocation!)
		} else {
			locationUpdateBlock = completion
			manager.startUpdatingLocation()
		}
	}
	
	// MARK: CLLocationManagerDelegate
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status != .NotDetermined {
			authorizationStatusBlock(CurrentLocation.authorized)
			authorizationStatusBlock = { authorized in }
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastLocation = locations[0]
		locationUpdateBlock(locations[0])
		locationUpdateBlock = { location in }
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("Failed to get location with error: \(error.localizedDescription).")
	}
}
