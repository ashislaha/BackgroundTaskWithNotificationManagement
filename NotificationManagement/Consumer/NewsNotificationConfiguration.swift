//
//  NewsNotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 08/05/22.
//

import Foundation

class NewsNotificationConfiguration: LocalNotificationConfiguration {
	
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
	
	// trigger this notification after every 2 min.
	var triggerWithTimeInterval: TimeInterval = TimeInterval(2 * 60)
	
	var backgroundAppRefreshTaskIdentifier = "com.news.localNotificationRefresh"
	
	private let endPoint = URL(string: "http://demo0660105.mockable.io/notifications")!
}
