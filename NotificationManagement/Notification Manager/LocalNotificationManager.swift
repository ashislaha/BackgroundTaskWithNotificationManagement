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
	
	func setUpNotification(with configuration: LocalNotificationConfiguration) {
		
		// content
		let content = UNMutableNotificationContent()
		content.title = configuration.localizedTitle
		content.body = configuration.localizedBody
		content.sound = .default
		
		// trigger
		var trigger: UNNotificationTrigger?
		
		switch configuration.triggerType {
		case .timeInterval:
			if let timeInterval = configuration.triggerWithTimeInterval, timeInterval >= 60  {
				trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
															repeats: false)
			}
		case .calendar:
			if let dateComponent = configuration.triggerWithDateComponent {
				trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent,
														repeats: false)
			}
		default: break
		}
		
		if let trigger = trigger {
			let request = UNNotificationRequest(identifier: configuration.backgroundAppRefreshTaskIdentifier,
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
					UserDefaults.standard.set(configuration.isRepeatativeTrigger,
											  forKey: configuration.backgroundAppRefreshTaskIdentifier)
					os_log("1. New Notification is added with ID - \(configuration.backgroundAppRefreshTaskIdentifier)")
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
		
		if let _ = UserDefaults.standard.value(forKey: requestIdentifier) as? Bool {
			unregisterNotification(with: requestIdentifier)
			BackGroundTaskScheduler.shared.cancelBackgroundAppRefresh(with: requestIdentifier)
		}
		
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
