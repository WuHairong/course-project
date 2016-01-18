//
//  LogInViewController.swift
//  Nibble
//
//  Created by Sachin on 11/21/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

class LogInViewController: UIViewController, UITextFieldDelegate {
	var logoView: NibbleLogoView
	var backButton: UIButton
	
	var statusBarUnderlapView: UIView
	var contentView: UIView
	
	var usernameField: NibbleTextField
	var passwordField: NibbleTextField
	
	var loginButton: UIButton
	var facebookButton: UIButton
	var forgotPasswordButton: UIButton
	
	// MARK: Init
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		statusBarUnderlapView = UIView()
		contentView = UIView()
		
		logoView = NibbleLogoView()
		backButton = UIButton()
		
		usernameField = NibbleTextField()
		passwordField = NibbleTextField()
		
		loginButton = UIButton.roundedButtonWithColor(UIColor.appTintColor())
		facebookButton = UIButton.roundedButtonWithColor(UIColor.facebookBlueColor())
		forgotPasswordButton = UIButton()
		
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

		usernameField.placeholder = "username"
		usernameField.returnKeyType = .Next
		usernameField.autocapitalizationType = .None
		usernameField.autocorrectionType = .No
		usernameField.delegate = self
		contentView.addSubview(usernameField)
		
		passwordField.placeholder = "password"
		passwordField.secureTextEntry = true
		passwordField.returnKeyType = .Done
		passwordField.delegate = self
		contentView.addSubview(passwordField)
		
		logoView.label.text = "Log in"
		contentView.addSubview(logoView)
		
		loginButton.setTitle("Log in", forState: .Normal)
		loginButton.addTarget(self, action: "login", forControlEvents: .TouchUpInside)
		contentView.addSubview(loginButton)
		
		facebookButton.setTitle("Log in with Facebook", forState: .Normal)
		facebookButton.addTarget(self, action: "loginWithFacebook", forControlEvents: .TouchUpInside)
		contentView.addSubview(facebookButton)
		
		forgotPasswordButton.setTitle("Forgot password?", forState: .Normal)
		forgotPasswordButton.setTitleColor(UIColor.appTintColor(), forState: .Normal)
		forgotPasswordButton.addTarget(self, action: "forgotPassword", forControlEvents: .TouchUpInside)
		contentView.addSubview(forgotPasswordButton)
	}
	
	// MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		statusBarUnderlapView.frame = CGRectMake(0, 0, view.frame.width, 20)
		contentView.frame = view.frame
		
		let margin = CGFloat(25)
		let bottomMargin = CGFloat(20)
		let logoSize = NibbleLogoView.preferredContentSize()
		let buttonSize = CGSizeMake(view.frame.width - margin * 2.0, 56.0)
		let fieldSize = CGSizeMake(view.frame.width - margin * 2.0, 44.0)
		
		logoView.frame = CGRectMake((view.frame.width - logoSize.width) / 2.0, 60.0, logoSize.width, logoSize.height)
		usernameField.frame = CGRectMake(margin, logoView.frame.maxY + 60.0, fieldSize.width, fieldSize.height)
		passwordField.frame = CGRectMake(margin, usernameField.frame.maxY + margin, fieldSize.width, fieldSize.height)
		loginButton.frame = CGRectMake(margin, passwordField.frame.maxY + margin, buttonSize.width, buttonSize.height)
		forgotPasswordButton.frame = CGRectMake(margin, loginButton.frame.maxY + margin, buttonSize.width, 30.0)
		facebookButton.frame = CGRectMake(margin, view.frame.height - bottomMargin - buttonSize.height, buttonSize.width, buttonSize.height)

		backButton.frame = CGRectMake(0, 35, 44, 44)
	}
	
	func login() {
		hideKeyboard()
		PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
			if user != nil {
				self.dismissViewControllerAnimated(true, completion: nil)
			} else {
				let alertController = UIAlertController(title: "Error Logging In", message: error?.localizedDescription, preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}
	
	func loginWithFacebook() {
		PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"]) { (user, error) -> Void in
			if user != nil {
				// Dismiss login view
				self.dismissViewControllerAnimated(true, completion: nil)
				
				// Get profile picture URL from Facebook and save to Parse
				let parameters = ["fields": "first_name, last_name, picture.type(large)"]
				FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
					if error == nil {
						if let fbUser = result as? [String: AnyObject], parseUser = user as? User {
							guard let firstName = fbUser["first_name"] as? String else { return }
							parseUser.firstName = firstName
							
							guard let lastName = fbUser["last_name"] as? String else { return }
							parseUser.lastName = lastName
							
							guard let pictureArray = fbUser["picture"] else { return }
							guard let dataArray = pictureArray["data"] as? [String: AnyObject] else { return }
							if let profilePictureURL = dataArray["url"] as? String {
								parseUser.profilePictureURL = profilePictureURL
							}
							
							// Save user
							parseUser.saveInBackground()
						}
					} else {
						// Ignore
					}
				})
			} else {
				let alertController = UIAlertController(title: "Error Logging In with Facebook", message: error?.localizedDescription, preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}
	
	func forgotPassword() {
		let alertController = UIAlertController(title: "Forgot Password?", message: "Enter your email address below to request a password reset.", preferredStyle: .Alert)
		let submitAction = UIAlertAction(title: "Submit", style: .Default) { (_) in
			let emailTextField = alertController.textFields![0] as UITextField
			PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!, block: { (finished, error) -> Void in
				alertController.dismissViewControllerAnimated(true, completion: nil)
			})
		}
		submitAction.enabled = false
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
		
		alertController.addTextFieldWithConfigurationHandler { (textField) in
			textField.placeholder = "Email address"
			textField.keyboardType = .EmailAddress
			NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
				submitAction.enabled = textField.text != ""
			}
		}
		
		alertController.addAction(submitAction)
		alertController.addAction(cancelAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	// MARK: Text Field and Keyboard Events
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == usernameField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			login()
		}
		return false
	}
	
	func hideKeyboard() {
		usernameField.resignFirstResponder()
		passwordField.resignFirstResponder()
	}
	
	func keyboardWillShow() {
		if usernameField.isFirstResponder() || passwordField.isFirstResponder() {
			UIView.animateWithDuration(0.15) { () -> Void in
				self.contentView.frame = CGRectMake(0, -140, self.view.frame.width, self.view.frame.height)
			}
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
