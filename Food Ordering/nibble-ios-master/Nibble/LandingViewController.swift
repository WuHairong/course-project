//
//  LandingViewController.swift
//  Nibble
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
	var logoView: NibbleLogoView
	var loginButton: UIButton
	var signupButton: UIButton
	
	// MARK: Init
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		logoView = NibbleLogoView()
		loginButton = UIButton.roundedButtonWithColor(UIColor.appTintColor())
		signupButton = UIButton.roundedButtonWithColor(UIColor.appTintColor())
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.whiteColor()
		
		logoView.label.text = "Nibble"
		view.addSubview(logoView)
		
		loginButton.setTitle("Log in", forState: .Normal)
		loginButton.addTarget(self, action: "pushLoginViewController", forControlEvents: .TouchUpInside)
		view.addSubview(loginButton)
		
		signupButton.setTitle("Sign up", forState: .Normal)
		signupButton.addTarget(self, action: "pushSignupViewController", forControlEvents: .TouchUpInside)
		view.addSubview(signupButton)
	}
	
	// MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let logoSize = NibbleLogoView.preferredContentSize()
		logoView.frame = CGRectMake((view.frame.width - logoSize.width) / 2.0, ((view.frame.height - logoSize.height) / 2.0) - 80.0, logoSize.width, logoSize.height)
		
		let margin = CGFloat(25)
		let bottomMargin = CGFloat(40)
		let buttonSize = CGSizeMake(view.frame.width - margin * 2.0, 56.0)
		signupButton.frame = CGRectMake(margin, view.frame.height - bottomMargin - buttonSize.height, buttonSize.width, buttonSize.height)
		loginButton.frame = CGRectMake(margin, signupButton.frame.minY - margin - buttonSize.height, buttonSize.width, buttonSize.height)
	}
	
	func pushLoginViewController() {
		let loginViewController = LogInViewController()
		navigationController?.pushViewController(loginViewController, animated: true)
	}

	func pushSignupViewController() {
		let signupViewController = SignUpViewController()
		navigationController?.pushViewController(signupViewController, animated: true)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
}
