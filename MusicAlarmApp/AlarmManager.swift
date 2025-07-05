import Foundation
import UserNotifications
import UIKit

class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var isAlarmActive = false
    @Published var scheduledAlarmTime: Date?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let alarmIdentifier = "com.musicalarm.alarm"
    
    private init() {
        setupNotificationObservers()
    }
    
    func scheduleAlarm(at time: Date) {
        // Cancel any existing alarm
        cancelAlarm()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Wake Up!"
        content.body = "Time to wake up with your music"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        // Create trigger for the alarm
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(identifier: alarmIdentifier, content: content, trigger: trigger)
        
        // Schedule notification
        notificationCenter.add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error scheduling alarm: \(error)")
                    self?.isAlarmActive = false
                } else {
                    print("Alarm scheduled successfully")
                    self?.isAlarmActive = true
                    self?.scheduledAlarmTime = time
                }
            }
        }
    }
    
    func cancelAlarm() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarmIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [alarmIdentifier])
        
        DispatchQueue.main.async {
            self.isAlarmActive = false
            self.scheduledAlarmTime = nil
        }
    }
    
    func checkAndTriggerAlarms() {
        guard let scheduledTime = scheduledAlarmTime else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        let scheduledComponents = calendar.dateComponents([.hour, .minute], from: scheduledTime)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        
        if scheduledComponents.hour == currentComponents.hour &&
           scheduledComponents.minute == currentComponents.minute {
            triggerAlarm()
        }
    }
    
    private func triggerAlarm() {
        DispatchQueue.main.async {
            // Start playing music
            MusicPlayer.shared.startPlayback()
            
            // Keep the app alive by preventing idle timer
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Post notification to update UI
            NotificationCenter.default.post(name: .alarmTriggered, object: nil)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAlarmNotification),
            name: .alarmTriggered,
            object: nil
        )
    }
    
    @objc private func handleAlarmNotification() {
        // Handle when alarm is triggered
        print("Alarm triggered!")
    }
}

extension Notification.Name {
    static let alarmTriggered = Notification.Name("alarmTriggered")
}