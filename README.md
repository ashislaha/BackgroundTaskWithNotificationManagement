# Background Task With Notification Management

## Resources On Background Task:

video --

https://developer.apple.com/videos/play/wwdc2020/10063

https://developer.apple.com/videos/play/wwdc2019/707


## Flows:

1. enable "capabilities" <-- "Background Modes" and choose "background fetch" and "background processing".
 background fetch -- periodically fetch likes social media feed, latest stocks etc.
 background processing -- database indexing, core ml training etc

2. Add Identifiers for the tasks in the plist file.


3. 	BGScheduler <-- Scheduler for those tasks which we want to execute in background.

Functionality of BGScheduler:

```
	 1. register a task
   
	 2. submit a task
   
	 3. cancel the task with identifier / OR we can cancel all the background tasks
   
	 4 get all the pending background tasks.
   
```
  
 ```
	BGTask <-- Defines a background task
  
	1. unique identifier
  
  2. set expiration time
  
 ```
	
  
There are two kind of tasks -- 

1. BGAppRefreshTaskRequest

2.  BGProcessingTaskRequest
	
  ```
  BGAppRefreshTaskRequest <-- for short time task like social media feed fetch, news feed fetch etc.

	BGProcessingTaskRequest <-- It gives several mins to sync (like database indexing etc)
  
  ```
 
## Local Notification handling :

https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html





  
