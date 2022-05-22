//
//  BackgroundNetworkService.swift
//  NotificationManagement
//
//  Created by Ashis Laha on 13/05/22.
//

import Foundation

class BackgroundNetworkService {
	
	private lazy var urlSession: URLSession = {
		let config = URLSessionConfiguration.background(withIdentifier: "NewsNotification")
		
		// system can wait for optimal condition (like switch back to Wifi, plugged in to battery) to complete the transfer
		config.isDiscretionary = true
		
		// to wake app your app when task is completed
		config.sessionSendsLaunchEvents = true
		return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
	}()
	
	func fetchNotificationData(endPoint: URL, completionHandler: @escaping ([String: String]?) -> (Void) ) {
		
		var urlRequest = URLRequest(url: endPoint)
		urlRequest.httpMethod = "GET"
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let backgroundTask = urlSession.dataTask(with: urlRequest) { data, response, error in
			
			if let data = data, error == nil {
				if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String] {
					completionHandler(dict)
				} else {
					completionHandler(nil)
				}
				
				if let httpResponse = response as? HTTPURLResponse,
				   (200...299).contains(httpResponse.statusCode) {
					
					guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String]
					else {
						completionHandler(nil)
						return
					}
					
					completionHandler(dictionary)
					
				} else {
					completionHandler(nil)
				}
				
			} else {
				completionHandler(nil)
			}
		}
		
		backgroundTask.countOfBytesClientExpectsToSend = 200
		backgroundTask.countOfBytesClientExpectsToReceive = 10 * 1024 // 10 KB
		backgroundTask.resume()
	}
	
}
