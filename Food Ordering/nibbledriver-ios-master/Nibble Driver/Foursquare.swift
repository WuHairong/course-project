//
//  Foursquare.swift
//  Nibble
//
//  Created by Sachin on 10/15/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import CoreLocation

import Parse
import Alamofire

class Foursquare: NSObject {
	static let server = "https://api.foursquare.com/v2/"
	
	static let apiVersion = "20151015"
	static let clientID = "HQ1DKETVQZ0YLJIGU0KHSOOLX2FMLOMLFOG2WU2QHRCMNC3E"
	static let clientSecret = "PJW3JSVN0U5NF02M4XQDFQAKZ1VCVHFPQQSVU10DEHQMPGM5"
	
	class func getVenues(query: String, categoryId: String, location: CLLocation, completion: ([Location], NSError?) -> ()) {
		if location.coordinate.latitude == 0.0 && location.coordinate.longitude == 0.0 {
			fatalError("This is probably a bug.")
		}
		let parameters = ["query": query, "categoryId": categoryId, "ll": "\(location.coordinate.latitude),\(location.coordinate.longitude)", "radius": "5000"]
		getEndpoint("venues/search", parameters: parameters, completion: { (JSON, error) -> () in
			guard let jsonDeRulo = JSON as? [String: AnyObject] else {
				completion([], NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			guard let response = (jsonDeRulo["response"] as? [String: AnyObject]) else {
				completion([], NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			guard let venues = response["venues"] as? [[String: AnyObject]] else {
				completion([], NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			
			// Convert Foursquare venues to our Location type
			var locations = [Location]()
			for venue in venues {
				// Validate venue properties
				guard let name = venue["name"] as? String else { continue }
				guard let venueLocation = venue["location"] as? [String: AnyObject] else { continue }
				guard let venueAddress = venueLocation["formattedAddress"] as? [String] else { continue }
				guard let latitude = venueLocation["lat"] as? Double else { continue }
				guard let longitude = venueLocation["lng"] as? Double else { continue }
				guard let id = venue["id"] as? String else { continue }
				
				// Map category dictionaries to strings
				var categoriesAsStrings = [String]()
				if let categories = venue["categories"] as? [[String: AnyObject]] {
					categoriesAsStrings = categories.map({ (category) -> String in
						guard let categoryString = category["shortName"] as? String else { return "" }
						return categoryString
					})
				}
				
				// Add menu URL if applicable
				var menuURL: String? = nil
				if let menu = venue["menu"] as? [String: String] {
					menuURL = menu["url"]
				}
				
				// Concatenate address strings
				var address = ""
				for component in venueAddress {
					address += "\(component), "
				}
				if address.characters.count > 3 {
					// Trim ", " from end
					address = address.substringToIndex(address.endIndex.predecessor().predecessor())
				}
				
				// Create the actual object
				let location = Location()
				location.name = name
				location.coordinate = PFGeoPoint(latitude: latitude, longitude: longitude)
				location.foursquareID = id
				location.categories = categoriesAsStrings
				location.address = address
				if menuURL != nil {
					location.url = menuURL!
				}
				locations.append(location)
			}
			completion(locations, nil)
		})
	}
	
	class func completeVenueAndSave(venue: Location, completion: (Location, NSError?) -> ()) {
		getEndpoint("venues/\(venue.foursquareID)", parameters: nil, completion: { (JSON, error) -> () in
			guard let jsonDeRulo = JSON as? [String: AnyObject] else {
				completion(venue, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			guard let response = (jsonDeRulo["response"] as? [String: AnyObject]) else {
				completion(venue, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			guard let completeVenue = response["venue"] as? [String: AnyObject] else {
				completion(venue, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			
			// Validate venue properties
			guard let canonicalURL = completeVenue["canonicalUrl"] as? String else { return }
			
			var rating = 0.0
			if let actualRating = completeVenue["rating"] as? Double {
				rating = actualRating
			}
			
			var priceTier = "$"
			if let attributes = completeVenue["attributes"] as? [String: AnyObject] {
				if let groups = attributes["groups"] as? [[String: AnyObject]] {
					for group in groups {
						guard let type = group["type"] as? String else { continue }
						if type == "price" {
							guard let summary = group["summary"] as? String else { return }
							priceTier = summary
						}
					}
				}
			}
			
			var photos = [Photo]()
			if let photosWrapper = completeVenue["photos"] as? [String: AnyObject],
				let groups = photosWrapper["groups"] as? [[String: AnyObject]] {
					for group in groups {
						guard let type = group["type"] as? String else { continue }
						if type == "venue" {
							if let photosArray = group["items"] as? [[String: AnyObject]] {
								for photoDictionary in photosArray {
									let photo = Photo()
									guard let photoID = photoDictionary["id"] as? String else { continue }
									guard let urlPrefix = photoDictionary["prefix"] as? String else { continue }
									guard let urlSuffix = photoDictionary["suffix"] as? String else { continue }
									guard let width = photoDictionary["width"] as? Int else { continue }
									guard let height = photoDictionary["height"] as? Int else { continue }
									
									photo.foursquareID = photoID
									photo.urlPrefix = urlPrefix
									photo.urlSuffix = urlSuffix
									photo.width = NSNumber(integer: width)
									photo.height = NSNumber(integer: height)
									photos.append(photo)
								}
							}
						}
					}
			}
			
			
			// Update the venue
			if photos.count > 0 {
				venue.thumbnailURL = photos[0].url().absoluteString
			}
			venue.foursquareURL = canonicalURL
			venue.rating = NSNumber(double: rating)
			venue.priceTier = priceTier
			
			venue.saveInBackgroundWithBlock({ (innerCompleted, innerError) -> Void in
				if let error = innerError {
					// Venue exists
					guard let venuePointer = NibbleParse.pointerFromDuplicateError(error, attemptedObject: venue) as? Location else {
						print("Error creating pointer from Parse error message.")
						return
					}
					venue.objectId = venuePointer.objectId
					completion(venue, nil)
				} else {
					// Save all photos, then save venue
					PFObject.saveAllInBackground(photos, block: { (innerCompleted2, innerError2) -> Void in
						// Add photos to relation and save venue again
						for photo in photos {
							let photoPointer = PFObject(withoutDataWithClassName: "Photo", objectId: photo.objectId)
							venue.photos.addObject(photoPointer)
						}
						venue.saveInBackgroundWithBlock({ (innerCompleted3, innerError3) -> Void in
							completion(venue, nil)
						})
					})
				}
			})
		})
	}

	private class func getEndpoint(endpoint: String, parameters: [String: AnyObject]?, completion: (AnyObject?, NSError?) -> ()) {
		let urlString = "\(server)\(endpoint)"
		
		var encodedParameters = [String: AnyObject]()
		if parameters != nil {
			encodedParameters = parameters!
		}
		
		encodedParameters["client_id"] = clientID
		encodedParameters["client_secret"] = clientSecret
		encodedParameters["v"] = apiVersion
		Alamofire.request(.GET, urlString, parameters: encodedParameters).responseJSON {
			response in
			completion(response.result.value, nil)
		}
	}
}
