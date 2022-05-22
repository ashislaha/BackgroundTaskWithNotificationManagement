//
//  SceneDelegate.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 29/04/22.
//

import UIKit
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }
		
		// local notification registration
		registerNotification { _ in }
		
		// register background tasks
		BackGroundTaskScheduler.shared.registerBackgroundTask()
		
		// checking the flow
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.app_refresh_test", using: .main) { task in
			self.handleTask(task: task as! BGAppRefreshTask)
		}
	}
	
	func handleTask(task: BGAppRefreshTask) {
		scheduleAppRefreshTask()
		
		
		UserDefaults.standard.set("\(Date())", forKey: "LastUpdate")
		UserDefaults.standard.synchronize()
		
		let configuration = TestLocalNotificationConfiguration()
		NotificationManager.shared.setUpNotification(with: configuration)
		
		task.setTaskCompleted(success: true)
	}
	
	func scheduleAppRefreshTask() {
		let configuration = TestLocalNotificationConfiguration()
		let schedule = BGAppRefreshTaskRequest(identifier: configuration.backgroundAppRefreshTaskIdentifier)
		schedule.earliestBeginDate = Date(timeIntervalSinceNow: configuration.triggerWithTimeInterval)
		
		do {
			try BGTaskScheduler.shared.submit(schedule)
			print("BG request submitted \(schedule.identifier)")
			
		} catch let error {
			print("Scene delegate: scheduleAppRefreshTask \(error.localizedDescription)")
		}
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
		
		BackGroundTaskScheduler.shared.scheduleBackgroundAppRefresh()
		
		scheduleAppRefreshTask()
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}
}

extension SceneDelegate {
	
	private func registerNotification(completionHandler: @escaping ((Bool) -> Void)) {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if error == nil {
				print("Local Notification Request granted \(granted)")
			}
			
			completionHandler(granted)
		}
	}
}

