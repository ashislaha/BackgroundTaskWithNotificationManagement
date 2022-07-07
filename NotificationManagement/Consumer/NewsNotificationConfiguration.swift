//
//  NewsNotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 08/05/22.
//

import Foundation

class NewsNotificationConfiguration: LocalNotificationConfiguration {
	
	var requestIdentifier: String = "News request ID"
	
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
	
	// trigger this notification after every 1 day.
	var triggerWithTimeInterval: TimeInterval = TimeInterval(60 * 60 * 24)
	
	var backgroundAppRefreshTaskIdentifier = "com.news.localNotificationRefresh"
	
	var backgroundProcessingTaskIdentifier: String = "com.news.bgProcessing"
	
	private let endPoint = URL(string: "http://demo0660105.mockable.io/notifications")!
}
