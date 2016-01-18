//
//  ConfirmedInterfaceController.swift
//  Nibble
//
//  Created by Sachin on 11/24/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import WatchKit
import Foundation


class ConfirmedInterfaceController: WKInterfaceController {
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
	
	@IBAction func done() {
		popToRootController()
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
