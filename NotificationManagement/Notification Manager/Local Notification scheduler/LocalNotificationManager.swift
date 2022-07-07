//
//  LocalNotificationManager.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 07/05/22.
//

/* Tutorial - https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html
*/

import Foundation
import UserNotifications
import os

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	
	static let shared = NotificationManager()
	
	private override init() {
		super.init()
	}
	
	func setUpNotification(with configuration: LocalNotificationConfiguration, shouldScheduleNow: Bool = false) {
		
		// content
		let content = UNMutableNotificationContent()
		content.title = configuration.localizedTitle
		content.body = configuration.localizedBody
		content.sound = .default
		
		// trigger
		var trigger: UNNotificationTrigger?
		
		if shouldScheduleNow {
			trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 /* minimum time is 1 min*/,
														repeats: configuration.isRepeatativeTrigger)
		} else {
			
			switch configuration.triggerType {
			case .timeInterval:
				if let timeInterval = configuration.triggerWithTimeInterval, timeInterval >= 60  {
					trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
																repeats: configuration.isRepeatativeTrigger)
				}
			case .calendar:
				if let dateComponent = configuration.triggerWithDateComponent {
					trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent,
															repeats: configuration.isRepeatativeTrigger)
				}
			default: break
			}
		}
		
		if let trigger = trigger {
			let request = UNNotificationRequest(identifier: configuration.requestIdentifier,
												content: content,
												trigger: trigger)
			
			// post the notification
			let center = UNUserNotificationCenter.current()
			center.delegate = self
			center.add(request) { error in
				if let error = error {
					print(error.localizedDescription)
				} else {
					// success
//					let backgroundTaskDict: [String: String] = [
//						"backgroundAppRefreshTaskId": configuration.backgroundAppRefreshTaskIdentifier,
//						"backgroundProcessingTaskId": configuration.backgroundProcessingTaskIdentifier
//					]
//					UserDefaults.standard.set(backgroundTaskDict, forKey: configuration.requestIdentifier)
					os_log("1. New Notification is added with ID - \(configuration.requestIdentifier)")
				}
			}
		}
		
	}
	
}

// MARK:- UNUserNotificationCenterDelegate

extension NotificationManager {
	
	// It is being called when the app is fore-ground
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		// update app interface directly
		os_log("3. willPresent notification - request ID \(notification.request.identifier)")
		
		// play a sound
		completionHandler([.sound, .badge])
	}
	
	// background and foreground
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		// request identifier
		let requestIdentifier = response.notification.request.identifier
		os_log("2. didReceive response - request ID \(requestIdentifier)")
		
		// reset local notification service
		unregisterNotification(with: requestIdentifier)
		
//		if let backgroundTaskIdsDict = UserDefaults.standard.value(forKey: requestIdentifier) as? [String: String] {
//
//			// reset app refresh task
//			if let bgAppRefrshTaskId = backgroundTaskIdsDict["backgroundAppRefreshTaskId"] {
//				BackGroundTaskScheduler.shared.cancelBackgroundTask(with: bgAppRefrshTaskId)
//			}
//
//			// reset background processing task
//			if let bgProcessingTaskId = backgroundTaskIdsDict["backgroundProcessingTaskId"] {
//				BackGroundTaskScheduler.shared.cancelBackgroundTask(with: bgProcessingTaskId)
//			}
//		}
		
		// system actions
		if response.actionIdentifier == UNNotificationDismissActionIdentifier {
			// User dismissed the notification interface explicitly witout selecting any custom actions.
			// Log an event
			os_log("2.2. User dismissed the notification interface")
			
		} else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
			// User landed into app, log an event
			os_log("2.3. User landed into app on tap of notification")
		}
		
		// handle custom actions if present (categoryIdentifier)
	}
	
	func unregisterNotification(with requestIdentifier: String) {
		
		// dismiss the repeatative trigger as it is not needed any more
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
		os_log("2.1 remove pending notifications -- request ID \(requestIdentifier)")
		
		// clean up the cache data
		UserDefaults.standard.removeObject(forKey: requestIdentifier)
	}
}
