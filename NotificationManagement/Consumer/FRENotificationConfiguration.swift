//
//  FRENotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 09/05/22.
//

import Foundation

class FRENotificationConfiguration: LocalNotificationConfiguration {
	
	var localizedTitle: String =  "Know the app"
	
	var localizedBody: String {
		get {
			return "Please check the First Run experience"
		}
		set {
			
		}
	}
	
	var triggerType: LocalNotificationTrigger = .timeInterval
	
	var isRepeatativeTrigger: Bool = false
	
	// trigger
	
	// trigger this notification after 1.5 min.
	var triggerWithTimeInterval: TimeInterval = TimeInterval(60 * 1.5)
	
	var backgroundAppRefreshTaskIdentifier = "com.fre.localNotificationRefresh"
}
