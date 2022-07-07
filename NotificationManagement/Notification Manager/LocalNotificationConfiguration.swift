//
//  LocalNotificationConfiguration.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 07/05/22.
//

import Foundation

/**
 
 As a part of configuration, we can ask the consumer to pass few details:
 
 1. notification content details (title and body)
 2. trigger information -- calendar, time inverval or location based trigger
 3. Do the trigger repeatative?
 4. Pass the GUID to identify uniquely the notification request.
 5. Do caller need any custom action in the notification? allow them to pass if caller wants.
	we need to update the categoryIdentifier of the notification content.
 */


@objc enum LocalNotificationTrigger: Int {
	case timeInterval = 0
	case calendar
	case location
}

@objc protocol LocalNotificationConfiguration: BGTaskConfiguration,
											   LocalNotificationRequestConfiguration,
												LocalNotificationContentConfiguration,
												LocalNotificationTriggerConfiguration {	
}

@objc protocol BGTaskConfiguration {
	
	var backgroundAppRefreshTaskIdentifier: String {get set}
	
	var backgroundProcessingTaskIdentifier: String { get set }
}

@objc protocol LocalNotificationRequestConfiguration: AnyObject {
	
	var requestIdentifier: String { get set }
}

@objc protocol LocalNotificationContentConfiguration: AnyObject {
	
	var localizedTitle: String {get set }
	
	var localizedBody: String {get set }	
}

@objc protocol LocalNotificationTriggerConfiguration: AnyObject {
	
	var triggerType: LocalNotificationTrigger {get set}
	
	var isRepeatativeTrigger: Bool {get set}
	
	@objc optional var triggerWithTimeInterval: TimeInterval {get set}
	
	@objc optional var triggerWithDateComponent: DateComponents {get set}
}
