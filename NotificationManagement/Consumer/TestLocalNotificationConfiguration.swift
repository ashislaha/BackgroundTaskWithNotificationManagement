//
//  TestLocalNotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 16/05/22.
//

import Foundation
import UIKit

class TestLocalNotificationConfiguration: LocalNotificationConfiguration {
	
	var localizedTitle: String =  "Testing..."
	
	var localizedBody: String {
		get {
			return "Notification has been scheduled through BGTask"
		}
		set {
			
		}
	}
	
	var triggerType: LocalNotificationTrigger = .timeInterval
	
	var isRepeatativeTrigger: Bool = true
	
	// trigger
	
	var triggerWithTimeInterval: TimeInterval = UIApplication.backgroundFetchIntervalMinimum
	
	var backgroundAppRefreshTaskIdentifier = "com.app_refresh_test"
}
