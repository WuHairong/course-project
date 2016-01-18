//
//  HomeViewController.swift
//  Nibble
//
//  Created by Sachin on 10/4/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import MapKit

import Parse
import AHKNavigationController

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
	let cellHeight = CGFloat(220)
	let cellIdentifier = "RestaurantCell"
	
	// UI
	var collectionView: UICollectionView
	
	// Data Source
	var locations: [Location]
	
	// MARK: Init
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.minimumInteritemSpacing = cellPadding
		collectionViewLayout.minimumLineSpacing = cellPadding
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
		locations = [Location]()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.backgroundColor = UIColor.clearColor()
		collectionView.alwaysBounceVertical = true
		collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(RestaurantCell.self, forCellWithReuseIdentifier: cellIdentifier)
		view.addSubview(collectionView)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Refresh when coming from background
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "forceRefresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
		
		title = "Nibble"
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "history-icon"), style: .Plain, target: self, action: "showHistory")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Collection view
		let collectionViewFrame = CGRectMake(0, 0, view.frame.width, view.frame.height)
		if !CGRectEqualToRect(collectionView.frame, collectionViewFrame) {
			collectionView.frame = collectionViewFrame
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		CurrentLocation.sharedInstance.requestAuthorization { (authorized) -> () in
			if !authorized {
				print("Unauthorized :(")
			} else {
				self.refresh(force: false)
			}
		}
		
		// Show login page if necessary
		if PFUser.currentUser() == nil {
			let landingViewController = LandingViewController()
			let landingNavigationController = AHKNavigationController(rootViewController: landingViewController)
			landingNavigationController.setNavigationBarHidden(true, animated: false)
			presentViewController(landingNavigationController, animated: false, completion: nil)
		} else {
			let sharedDefaults = NSUserDefaults(suiteName: "group.com.SachinPatel.Nibble")
			sharedDefaults?.setValue(PFUser.currentUser()!.objectId!, forKeyPath: "userId")
			sharedDefaults?.synchronize()
		}
	}
	
	func forceRefresh() {
		refresh(force: true)
	}
	
	func refresh(force force: Bool) {
		if locations.count == 0 || force {
			CurrentLocation.sharedInstance.get({ (location) -> () in
				// Center on current location on the map
				PFCloud.callFunctionInBackground("validRestaurants", withParameters: nil, block: { (results, error) -> Void in
					if let venues = results as? [Location] {
						self.locations = venues
						
						var annotations = [RestaurantAnnotation]()
						for venue in venues {
							let annotation = RestaurantAnnotation(location: venue)
							annotations.append(annotation)
						}
						
						self.collectionView.reloadData()
					}
				})
			})
		}
	}
	
	// MARK: - Collection View
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return locations.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? RestaurantCell {
			cell.restaurant = locations[indexPath.row]			
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		
		let restaurantViewController = RestaurantViewController(restaurant: locations[indexPath.row])
		navigationController?.pushViewController(restaurantViewController, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(view.frame.width, cellHeight)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 0, cellPadding, 0)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		for cell in collectionView.visibleCells() {
			guard let restaurantCell = cell as? RestaurantCell else { continue }

			let yOffset = ((collectionView.contentOffset.y / collectionView.contentSize.height) * RestaurantCellConstants.imageOffsetSpeed)
			restaurantCell.imageOffset = CGPointMake(0, yOffset)
		}
	}
	
	// MARK: - History
	func showHistory() {
		let historyViewController = HistoryViewController()
		let navigationController = UINavigationController(rootViewController: historyViewController)
		navigationController.delegate = self
		presentViewController(navigationController, animated: true, completion: nil)
	}
	
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		if let _ = viewController as? HistoryDetailViewController where navigationController.navigationBarHidden == false {
			navigationController.setNavigationBarHidden(true, animated: true)
		} else if navigationController.navigationBarHidden == true {
			navigationController.setNavigationBarHidden(false, animated: true)
		}
	}
}
