//
//  FRENotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 09/05/22.
//

import UIKit

class FRENotificationConfiguration: LocalNotificationConfiguration {
	
	var requestIdentifier: String = "FRE request ID"
	
	var localizedTitle: String =  "Know the app"
	
	var localizedBody: String {
		get {
			return "Please check the First Run experience)"
		}
		set {
			
		}
	}
	
	var triggerType: LocalNotificationTrigger = .timeInterval
	
	var isRepeatativeTrigger: Bool = false
	
	// trigger
	
	// trigger this notification after 2 min when BGTask is not running
	var triggerWithTimeInterval: TimeInterval = TimeInterval(60 * 1.5)
	
	var backgroundAppRefreshTaskIdentifier = "com.fre.localNotificationRefresh"
	
	var backgroundProcessingTaskIdentifier: String = "com.fre.bgProcessing"
}
