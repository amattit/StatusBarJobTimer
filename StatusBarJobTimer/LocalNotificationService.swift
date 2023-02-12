//
//  LocalNotificationService.swift
//  StatusBarJobTimer
//
//  Created by Михаил Серегин on 11.02.2023.
//

import Foundation
import UserNotifications

final class LocalNotificationService {
    func addNotification(_ notificationType: NotificationType) {
        UNUserNotificationCenter.current().add(notificationType.request) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func requestAuth() {
        UNUserNotificationCenter.current().requestAuthorization { isSuccess, error in
            print(isSuccess)
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func clearQueue() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

enum NotificationType {
    case pauseAt(TimeInterval), resumeAt(TimeInterval)
    
    private var content: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .defaultCritical
        switch self {
        case .pauseAt:
            content.title = "Время отдохнуть!"
            content.body = "Попей чай или водички"
        case .resumeAt:
            content.title = "Пора продолжать совершать подвиг!"
            content.body = "Вдохни и вперед за работу"
        }
        return content
    }
    
    private var trigger: UNCalendarNotificationTrigger {
        
        let components: DateComponents!
        
        switch self {
        case .pauseAt(let pauseAt):
            components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date().advanced(by: pauseAt))
        case .resumeAt(let resumeAt):
            components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date().advanced(by: resumeAt))
        }
        
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    var request: UNNotificationRequest {
        return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }
}
