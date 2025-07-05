import UIKit
import BackgroundTasks
import UserNotifications
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied")
            }
        }
        
        // Register for background tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.musicalarm.background-refresh", using: nil) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
        
        // Configure audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundRefresh()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Cancel background refresh when entering foreground
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.musicalarm.background-refresh")
    }
    
    // MARK: - Background Tasks
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.musicalarm.background-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // 5 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
    
    func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Check if alarm should trigger
        AlarmManager.shared.checkAndTriggerAlarms()
        
        // Schedule next background refresh
        scheduleBackgroundRefresh()
        
        // Complete the task
        task.setTaskCompleted(success: true)
    }
}