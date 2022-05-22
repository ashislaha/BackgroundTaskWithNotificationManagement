//
//  BackGroundTaskScheduler.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 11/05/22.
//

import Foundation
import BackgroundTasks
import OSLog

// video --
// https://developer.apple.com/videos/play/wwdc2020/10063
// https://developer.apple.com/videos/play/wwdc2019/707

// 1. enable "capabilities" <-- "Background Modes" and choose "background fetch" and "background processing".
// background fetch -- periodically fetch likes social media feed, latest stocks etc.
// background processing -- database indexing, core ml training etc

// 2. Add Identifiers for the tasks in the plist file.

class BackGroundTaskScheduler {
	
	// BGScheduler <-- Scheduler for those tasks which we want to execute in background.
	// 1. register a task
	// 2. submit a task
	// 3. cancel the task with identifier / OR we can cancel all the background tasks
	// 4 get all the pending background tasks.
	
	
	// BGTask <-- Defines a background task
	// 1. unique identifier
	// 2. set expiration time
	
	// There is two kind of tasks -- 1. BGAppRefreshTaskRequest 2. BGProcessingTaskRequest
	
	// 1. BGAppRefreshTaskRequest <-- for short time task like social media feed fetch, news feed fetch etc.
	// 30 sec is the time for the execution.
	
	// 2. BGProcessingTaskRequest <-- It gives several mins to sync (like database indexing etc)
	
	static let shared = BackGroundTaskScheduler()
	var backgroundRequestsMap: [String: LocalNotificationConfiguration] = [:]
	
	
	// MARK: - Registration
	
	// Optimisation -- check whether the user is currently "Low power mode" or not
	// based on that -- we can register on state change notification and update the state.
	
	func registerBackgroundTask() {
		
		// news
		let newsNotificationConfiguration = NewsNotificationConfiguration()
		registerBackgroundSchedule(with: newsNotificationConfiguration)
		backgroundRequestsMap[newsNotificationConfiguration.backgroundAppRefreshTaskIdentifier] =  newsNotificationConfiguration
		
		// fre
		let freNotificationConfiguration = FRENotificationConfiguration()
		registerBackgroundSchedule(with: freNotificationConfiguration)
		backgroundRequestsMap[freNotificationConfiguration.backgroundAppRefreshTaskIdentifier] =  freNotificationConfiguration
		
	}
	
	private func registerBackgroundSchedule(with configuration: LocalNotificationConfiguration) {
		
		BGTaskScheduler.shared.register(forTaskWithIdentifier: configuration.backgroundAppRefreshTaskIdentifier,
										using: .main) { bgTask in
			// Log the information
			os_log("Background app refresh registration")
			
			// handle app refresh task
			self.handleAndRescheuleIfNeededLocalNotifications(task: bgTask as! BGAppRefreshTask)
		}
	}
	
	// MARK: - Schedule
	
	func scheduleBackgroundAppRefresh() {
		for (_, eachRequest) in backgroundRequestsMap {
			scheduleBackgroundAppRefresh(with: eachRequest)
		}
	}
	
	private func scheduleBackgroundAppRefresh(with configuration: LocalNotificationConfiguration) {
		let request = BGAppRefreshTaskRequest(identifier: configuration.backgroundAppRefreshTaskIdentifier)
		
		if configuration.triggerType == .timeInterval, let interval = configuration.triggerWithTimeInterval {
			request.earliestBeginDate = Date(timeIntervalSinceNow: interval) // refresh after x min
		} else {
			// default ( pending - handle it for .location and .calendar event)
			request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // after 5 mins
		}
		
		do {
			try BGTaskScheduler.shared.submit(request)
			print("BG AppRefresh Task submitted - \(configuration.backgroundAppRefreshTaskIdentifier)")
			
		} catch let error {
			print("Could not schedule app refresh \(error.localizedDescription)")
		}
	}
	
	// MARK: - Cancellation
	
	func cancelBackgroundAppRefresh(with identifier: String) {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
	}
	
	
	// MARK: - Handling (and reschedule if needed)
	
	private func handleAndRescheuleIfNeededLocalNotifications(task: BGAppRefreshTask) {
		
		UserDefaults.standard.set(Date(), forKey: "LastUpdate")
		UserDefaults.standard.synchronize()
		
		guard let configuration: LocalNotificationConfiguration = backgroundRequestsMap[task.identifier]
		else { return }
		
//		if task.identifier == "com.news.freNotificationRefresh" {
//			configuration = FRENotificationConfiguration()
//		} else {
//			configuration = NewsNotificationConfiguration()
//		}
		
		if configuration.isRepeatativeTrigger {
			// schedule a new app-refresh request so that it will continue to fetch the data
			scheduleBackgroundAppRefresh(with: configuration)
		}
		
		// fetch new data for title and body and update configuration if needed
		NotificationManager.shared.setUpNotification(with: configuration)
		task.setTaskCompleted(success: true)
		
		
		/*
		let operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
		
		let operation = BlockOperation {
			print("You can do more work here")
		}
		operationQueue.addOperation(operation)
		
		operation.completionBlock = {
			task.setTaskCompleted(success: !operation.isCancelled)
		}
		 */
		
		task.expirationHandler = {
			// execute the code if the time out happens
			// like we can cancel the operations from operation queue if they are ready to execute / currently executing.
		}
	}
}


// MARK: - BakgroundProcessing

extension BackGroundTaskScheduler {
	
	func scheduleBackgroundProcessing() {
		let request = BGProcessingTaskRequest(identifier: "com.feed.database_cleaning")
		request.requiresNetworkConnectivity = true // if we want to fetch any data from network
		request.requiresExternalPower = true
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // after an hour
		
		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("could not schedule the network fetch request")
		}
	}
}
