//
//  ViewController.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 29/04/22.
//

import UIKit

// use-case
// we will create 2 local notification channel with repeatative patter.
// Notification will be post to the devices after certain interval
// Once it is tapped by the user, remove the pending scheduled notifications


class ViewController: UIViewController {
	
	@IBOutlet weak var lastUpdated: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// update last update label based on last background refresh
		if let lastUpdate = UserDefaults.standard.value(forKey: "LastUpdate") as? String {
			lastUpdated.text = lastUpdate
		} else {
			lastUpdated.text = "No BG refresh till now"
		}
	}
	
}



