//
//  HistoryDetailDriverCell.swift
//  Nibble
//
//  Created by Varun Arora on 11/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit
import Parse
import Foundation

class HistoryDetailDriverCell: UITableViewCell {
    
    // MARK: Contents
    var driver: User? {
        didSet {
            if ((driver?.username?.characters.count <= 0)) {
                textLabel?.text = "Driver Unassigned"
            } else {
                textLabel?.text = driver?.firstName
				var imageURL = driver?.profilePictureURL
				if let driverProfilePicture = driver?.profilePicture {
					imageURL = driverProfilePicture.url
				}
				dispatch_async(dispatch_get_main_queue(), {
					self.profilePictureView.sd_setImageWithURL(NSURL(string: imageURL!)!)
				})
            }
        }
    }
	
    let contactButton: UIButton
    var profilePictureView: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        contactButton = UIButton()
        profilePictureView = UIImageView()
		
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        textLabel?.font = UIFont.appFontOfSize(24, weight: .Regular)
		
        contactButton.setTitle("Contact Driver", forState: UIControlState.Normal)
        contactButton.setTitleColor(UIColor.appTintColor(), forState: UIControlState.Normal)
        contactButton.titleLabel?.font = UIFont.appFontOfSize(16, weight: .Regular)
        contactButton.addTarget(self, action: "goToMail:", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(contactButton)
        
        profilePictureView.clipsToBounds = true
        profilePictureView.contentMode = .ScaleAspectFill
		profilePictureView.backgroundColor = UIColor.lightGrayColor()
        contentView.addSubview(profilePictureView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftMargin = CGFloat(15)
        
        let pictureDimension = CGFloat(50)
        profilePictureView.frame = CGRectMake(leftMargin, contentView.center.y - pictureDimension/2, pictureDimension, pictureDimension)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.width/2
        
        let driverNameLeftMargin = CGFloat(10)
        let textLabelX = leftMargin+profilePictureView.frame.width+driverNameLeftMargin
        let textLabelY = contentView.center.y-6
        if ((driver?.username) == nil) {
            let textLabelWidth1 = frame.maxX - textLabelX
            textLabel?.frame = CGRectMake(textLabelX, textLabelY, textLabelWidth1, 24)
        } else {
            let contactLabelX = contentView.frame.maxX - 130
            contactButton.frame = CGRectMake(contactLabelX, 0, 125, frame.height)
            let textLabelWidth2 = contactButton.frame.minX - textLabelX
            textLabel?.frame = CGRectMake(textLabelX, textLabelY, textLabelWidth2 , 24)
        }
    }
    
    func goToMail(sender:UIButton?) {
        let email = driver?.email
        if (email?.characters.count>0) {
            let emailURL = NSURL(string: "mailto:\(email!)?subject=Question%20about%20my%20order")
            UIApplication.sharedApplication().openURL(emailURL!)
        }
    }
}
