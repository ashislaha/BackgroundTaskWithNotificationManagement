//
//  NewsNotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 08/05/22.
//

import Foundation

class NewsNotificationConfiguration: LocalNotificationConfiguration {

	var notificationRequestIdentifier: String = "News Local Notification ID"
	
	var localizedTitle: String =  "News Update"
	
	var localizedBody: String {
		get {
			return "We won the match."
		}
		set {
			
		}
	}
	
	var triggerType: LocalNotificationTrigger = .timeInterval
	
	var isRepeatativeTrigger: Bool = true
	
	// trigger
	
	// trigger this notification after every 1.5 min.
	var triggerWithTimeInterval: TimeInterval = TimeInterval(60*1.5)
}
