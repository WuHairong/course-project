//
//  SignUpViewController.swift
//  Nibble
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

class SignUpViewController: UIViewController, UITextFieldDelegate {
	var logoView: NibbleLogoView
	var backButton: UIButton
	
	var statusBarUnderlapView: UIView
	var contentView: UIView
	
	var firstNameField: NibbleTextField
	var lastNameField: NibbleTextField
	var usernameField: NibbleTextField
	var emailField: NibbleTextField
	var passwordField: NibbleTextField
	
	var signupButton: UIButton
	
	// MARK: Init
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		statusBarUnderlapView = UIView()
		contentView = UIView()
		
		logoView = NibbleLogoView()
		backButton = UIButton()
		
		firstNameField = NibbleTextField()
		lastNameField = NibbleTextField()
		usernameField = NibbleTextField()
		emailField = NibbleTextField()
		passwordField = NibbleTextField()
		
		signupButton = UIButton.roundedButtonWithColor(UIColor.appTintColor())
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	func commonInit() {
		view.backgroundColor = UIColor.whiteColor()
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
		contentView.addGestureRecognizer(gestureRecognizer)
		view.addSubview(contentView)
		
		statusBarUnderlapView.backgroundColor = UIColor.whiteColor()
		view.addSubview(statusBarUnderlapView)
		
		backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
		backButton.setImage(UIImage(named: "Back")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		backButton.tintColor = UIColor.lightGrayColor()
		view.addSubview(backButton)

		firstNameField.placeholder = "first name"
		firstNameField.returnKeyType = .Next
		firstNameField.autocorrectionType = .No
		firstNameField.delegate = self
		contentView.addSubview(firstNameField)
		
		lastNameField.placeholder = "last name"
		lastNameField.returnKeyType = .Next
		lastNameField.autocorrectionType = .No
		lastNameField.delegate = self
		contentView.addSubview(lastNameField)
		
		usernameField.placeholder = "username"
		usernameField.returnKeyType = .Next
		usernameField.autocapitalizationType = .None
		usernameField.autocorrectionType = .No
		usernameField.delegate = self
		contentView.addSubview(usernameField)

		emailField.placeholder = "email address"
		emailField.keyboardType = .EmailAddress
		emailField.returnKeyType = .Next
		emailField.autocapitalizationType = .None
		emailField.autocorrectionType = .No
		emailField.delegate = self
		contentView.addSubview(emailField)
		
		passwordField.placeholder = "password"
		passwordField.secureTextEntry = true
		passwordField.returnKeyType = .Done
		passwordField.delegate = self
		contentView.addSubview(passwordField)
		
		logoView.label.text = "Sign up"
		contentView.addSubview(logoView)
		
		signupButton.setTitle("Sign up", forState: .Normal)
		signupButton.addTarget(self, action: "signup", forControlEvents: .TouchUpInside)
		contentView.addSubview(signupButton)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		firstNameField.becomeFirstResponder()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		statusBarUnderlapView.frame = CGRectMake(0, 0, view.frame.width, 20)
		contentView.frame = view.frame
		
		let margin = CGFloat(20)
		let logoSize = NibbleLogoView.preferredContentSize()
		let buttonSize = CGSizeMake(view.frame.width - margin * 2.0, 56.0)
		let fieldSize = CGSizeMake(view.frame.width - margin * 2.0, 44.0)
		
		logoView.frame = CGRectMake((view.frame.width - logoSize.width) / 2.0, 60.0, logoSize.width, logoSize.height)
		firstNameField.frame = CGRectMake(margin, logoView.frame.maxY + 40.0, fieldSize.width / 2.0 - margin / 2.0, fieldSize.height)
		lastNameField.frame = CGRectMake(firstNameField.frame.maxX + margin / 2.0, firstNameField.frame.minY, fieldSize.width / 2.0 - margin / 2.0, fieldSize.height)
		usernameField.frame = CGRectMake(margin, firstNameField.frame.maxY + margin, fieldSize.width, fieldSize.height)
		emailField.frame = CGRectMake(margin, usernameField.frame.maxY + margin, fieldSize.width, fieldSize.height)
		passwordField.frame = CGRectMake(margin, emailField.frame.maxY + margin, fieldSize.width, fieldSize.height)
		signupButton.frame = CGRectMake(margin, passwordField.frame.maxY + margin, buttonSize.width, buttonSize.height)
		
		backButton.frame = CGRectMake(0, 35, 44, 44)
	}
	
	func signup() {
		hideKeyboard()
		
		let user = User()
		user.username = usernameField.text!
		user.password = passwordField.text!
		user.email = emailField.text!
		user.firstName = firstNameField.text!
		user.lastName = lastNameField.text!
		user.signUpInBackgroundWithBlock { (success, error) -> Void in
			if success == true {
				self.dismissViewControllerAnimated(true, completion: nil)
			} else {
				let alertController = UIAlertController(title: "Error Signing Up", message: error?.localizedDescription, preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}
	
	
	// MARK: - Text Field and Keyboard Events
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == firstNameField {
			lastNameField.becomeFirstResponder()
		} else if textField == lastNameField {
			usernameField.becomeFirstResponder()
		} else if textField == usernameField {
			emailField.becomeFirstResponder()
		} else if textField == emailField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			signup()
		}
		return false
	}
	
	func hideKeyboard() {
		firstNameField.resignFirstResponder()
		lastNameField.resignFirstResponder()
		usernameField.resignFirstResponder()
		emailField.resignFirstResponder()
		passwordField.resignFirstResponder()
	}
	
	func keyboardWillShow() {
		UIView.animateWithDuration(0.15) { () -> Void in
			self.contentView.frame = CGRectMake(0, -145, self.view.frame.width, self.view.frame.height)
		}
	}
	
	func keyboardWillHide() {
		UIView.animateWithDuration(0.15) { () -> Void in
			self.contentView.frame = self.view.frame
		}
	}
	
	func back() {
		navigationController?.popViewControllerAnimated(true)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
