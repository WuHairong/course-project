//
//  AppDelegate.swift
//  Nibble
//
//  Created by Sachin on 10/4/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import AHKNavigationController

let cellPadding = CGFloat(15)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
	var window: UIWindow?
	var homeViewController = HomeViewController()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.backgroundColor = UIColor.whiteColor()
		window?.tintColor = UIColor.appTintColor()
		
		// Configure Parse
        User.registerSubclass()
		Location.registerSubclass()
		Order.registerSubclass()
        Post.registerSubclass()
        Photo.registerSubclass()
		Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.SachinPatel.Nibble")
		Parse.setApplicationId("zFLGCSep1Jefdj9ZqCU69q59kKmiS9Tx9j33CCAI", clientKey: "NPzFgNF1LV5nXruwjmZRvGtp19rrrPqLLFboeync")
		PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
		
		// Set up push (ideally we'd have a better UI for this but we're out of time)
		let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
		application.registerUserNotificationSettings(settings)
		application.registerForRemoteNotifications()
        
		// Create main navigation controller
		let navigationController = AHKNavigationController(rootViewController: homeViewController)
		navigationController.delegate = self
	    window?.rootViewController = navigationController
		
		configureStyle()
		window?.makeKeyAndVisible()
		
		return true
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
				User.currentUser()?.appInstallation = installationPointer
				User.currentUser()?.saveInBackground()
			}
		}
	}
 
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		if error.code == 3010 {
			print("Push notifications are not supported in the iOS Simulator.")
		} else {
			print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
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

	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(application,
			openURL: url,
			sourceApplication: sourceApplication,
			annotation: annotation)
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		FBSDKAppEvents.activateApp()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		if let _ = viewController as? RestaurantViewController where navigationController.navigationBarHidden == false {
			navigationController.setNavigationBarHidden(true, animated: true)
		} else if navigationController.navigationBarHidden == true {
			navigationController.setNavigationBarHidden(false, animated: true)
		}
	}
}

