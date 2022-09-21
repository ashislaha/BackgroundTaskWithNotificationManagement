//
//  BackGroundTaskScheduler.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 11/05/22.
//

import UIKit
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
			os_log("Background app refresh task is executing.")
			
			// handle app refresh task
			self.handleAndRescheuleIfNeededLocalNotifications(task: bgTask)
		}
		
		/*
		BGTaskScheduler.shared.register(forTaskWithIdentifier: configuration.backgroundProcessingTaskIdentifier, using: .main) { bgTask in
			
			os_log("Background processing task is executing")
			self.handleAndRescheuleIfNeededLocalNotifications(task: bgTask)
		}
		 */
		
	}
	
	// MARK: - Schedule
	
	func scheduleBackgroundAppRefresh() {
		for (_, eachRequest) in backgroundRequestsMap {
			scheduleBackgroundAppRefresh(with: eachRequest)
		}
	}
	
	private func scheduleBackgroundAppRefresh(with configuration: LocalNotificationConfiguration) {
		
		// background app refresh
		let minimumTimeToFetch = Date(timeIntervalSinceNow: UIApplication.backgroundFetchIntervalMinimum)
		let request = BGAppRefreshTaskRequest(identifier: configuration.backgroundAppRefreshTaskIdentifier)
		request.earliestBeginDate = minimumTimeToFetch
		
		do {
			try BGTaskScheduler.shared.submit(request)
			print("BG AppRefresh Task submitted - \(configuration.backgroundAppRefreshTaskIdentifier)")
			
		} catch let error {
			print("Could not schedule app refresh \(error.localizedDescription)")
		}
		
		// background processing task
		/*
		let requestProcessingTask = BGProcessingTaskRequest(identifier: configuration.backgroundProcessingTaskIdentifier)
		requestProcessingTask.earliestBeginDate = minimumTimeToFetch
		
		do {
			try BGTaskScheduler.shared.submit(requestProcessingTask)
			print("BG AppRefresh Task submitted - \(configuration.backgroundProcessingTaskIdentifier)")
			
		} catch let error {
			print("Could not schedule app refresh \(error.localizedDescription)")
		}
		*/
	}
	
	// MARK: - Cancellation
	
	func cancelBackgroundTask(with identifier: String) {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
	}
	
	// MARK: - Handling (and reschedule if needed)
	
	private func handleAndRescheuleIfNeededLocalNotifications(task: BGTask) {
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.saveLog(input: "BGTask: \(Date())")
		}
		
		UserDefaults.standard.set(Date(), forKey: "LastUpdate")
		UserDefaults.standard.synchronize()
		
		var configuration: LocalNotificationConfiguration!
		
		if task.identifier == "com.myapp.news.localNotificationRefresh" {
			configuration = NewsNotificationConfiguration()
		} else {
			configuration = FRENotificationConfiguration()
		}
		
		// cancel if any pending static local notification scheduled before
		NotificationManager.shared.unregisterNotification(with: configuration.requestIdentifier)
		
		// alter the body of the notification with BGTask tag
		let body = configuration.localizedBody
		configuration.localizedBody = body + " [BGTask \(Date())]"
		
		if configuration.isRepeatativeTrigger {
			// schedule a new app-refresh request so that it will continue to fetch the data
			scheduleBackgroundAppRefresh(with: configuration)
		}
		
		NotificationManager.shared.setUpNotification(with: configuration, shouldScheduleNow: true)
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
