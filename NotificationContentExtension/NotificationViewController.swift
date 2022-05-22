//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Ashis Laha on 10/05/22.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
	@IBOutlet weak var body: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.title + "[modified]"
		self.body.text = notification.request.content.body + "[modified]"
    }

}
