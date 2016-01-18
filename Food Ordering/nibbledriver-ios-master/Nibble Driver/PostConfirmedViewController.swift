//
//  PostConfirmedViewController.swift
//  Nibble
//
//  Created by Sachin on 11/20/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class PostConfirmedViewController: UIViewController {
	var confirmedView: PostConfirmedView
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		confirmedView = PostConfirmedView()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.appBackgroundColor()
		view.addSubview(confirmedView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Now Online"
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let size = CGSizeMake(view.frame.width - 80.0, 320.0)
		confirmedView.frame = CGRectMake(40.0, ((view.frame.height - size.height) / 2.0) - 30.0, size.width, size.height)
	}
	
	func done() {
		dismissViewControllerAnimated(true, completion: nil)
	}
}
