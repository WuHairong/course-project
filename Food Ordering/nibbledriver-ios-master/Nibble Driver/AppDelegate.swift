//
//  AppDelegate.swift
//  Nibble Driver
//
//  Created by Sachin on 10/4/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	// These map directly to identifiers in our Cloud Code
	let orderRequestActionCategoryIdentifier = "ORDER_REQUEST"
	let acceptActionIdentifier = "ACCEPT"
	let ignoreActionIdentifier = "IGNORE"
	
	var window: UIWindow?
	var homeViewController = DashboardViewController()
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.backgroundColor = UIColor.whiteColor()
		window?.tintColor = UIColor.appTintColor()
		
		// Configure Parse
		User.registerSubclass()
		Location.registerSubclass()
		Order.registerSubclass()
		Post.registerSubclass()
		Photo.registerSubclass()
		Parse.setApplicationId("zFLGCSep1Jefdj9ZqCU69q59kKmiS9Tx9j33CCAI", clientKey: "NPzFgNF1LV5nXruwjmZRvGtp19rrrPqLLFboeync")
		PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
		
		// Create main navigation controller
		let navigationController = UINavigationController(rootViewController: homeViewController)
		window?.rootViewController = navigationController
		
		registerPush()
		configureStyle()
		
		window?.makeKeyAndVisible()
		
		return true
	}
	
	func registerPush() {
		let acceptAction = UIMutableUserNotificationAction()
		acceptAction.identifier = acceptActionIdentifier
		acceptAction.title = "Accept"
		acceptAction.activationMode = .Background
		acceptAction.destructive = false
		
		let ignoreAction = UIMutableUserNotificationAction()
		ignoreAction.identifier = ignoreActionIdentifier
		ignoreAction.title = "Ignore"
		ignoreAction.activationMode = .Background
		ignoreAction.destructive = false
		
		let category = UIMutableUserNotificationCategory()
		category.identifier = orderRequestActionCategoryIdentifier
		category.setActions([acceptAction, ignoreAction], forContext: .Minimal)

		let actionSet = Set(arrayLiteral: category)
		
		let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: actionSet)
		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
	}
	
	func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
		guard let userInfoDict = userInfo as? [String: AnyObject] else { return }
		guard let objectId = userInfoDict["objectId"] as? String else { return }
		if identifier == acceptActionIdentifier || identifier == ignoreActionIdentifier {
			let postsQuery = User.currentUser()?.posts.query()
			postsQuery?.includeKey("restaurant")
			postsQuery?.includeKey("deliveryLocation")
			postsQuery?.limit = 1
			postsQuery?.orderByDescending("createdAt")
			postsQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
				if error == nil {
					if let post = objects?[0] as? Post {
						// Pending orders
						let pendingOrdersQuery = post.pendingOrders.query()
						pendingOrdersQuery?.whereKey("objectId", equalTo: objectId)
						pendingOrdersQuery?.getFirstObjectInBackgroundWithBlock({ (order, error) -> Void in
							if error == nil {
								if identifier == self.acceptActionIdentifier {
									PFCloud.callFunctionInBackground("acceptOrder", withParameters: ["objectId": order!.objectId!]) { (result, error) -> Void in
										if error != nil {
											NSLog(error!.localizedDescription)
										}
										completionHandler()
									}
								} else if identifier == self.ignoreActionIdentifier {
									PFCloud.callFunctionInBackground("rejectOrder", withParameters: ["objectId": order!.objectId!]) { (result, error) -> Void in
										if error != nil {
											NSLog(error!.localizedDescription)
										}
										completionHandler()
									}
								}
							} else {
								completionHandler()
							}
						})
					} else {
						completionHandler()
					}
				}
			})
		}
	}
	
	func configureStyle() {
		// UIBarButtonItem
		let attributes = [NSFontAttributeName: UIFont.appFontOfSize(18, weight: .Regular)]
		UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: .Normal)
		
		// UINavigationBar
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.appFontOfSize(20, weight: .Medium)]
		UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
		UINavigationBar.appearance().translucent = false
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		let installation = PFInstallation.currentInstallation()
		installation.setDeviceTokenFromData(deviceToken)
		installation.channels = ["global"]
		installation.saveInBackgroundWithBlock { (success, error) -> Void in
			if error == nil {
				let installationPointer = PFObject(withoutDataWithClassName: "_Installation", objectId: installation.objectId!)
				User.currentUser()?.driverAppInstallation = installationPointer
				User.currentUser()?.saveInBackground()
			}
		}
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		PFPush.handlePush(userInfo)
		if application.applicationState == UIApplicationState.Inactive {
			PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
		}
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		FBSDKAppEvents.activateApp()
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(application,
			openURL: url,
			sourceApplication: sourceApplication,
			annotation: annotation)
	}
	
	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	
}

