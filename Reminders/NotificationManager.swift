//
//  NotificationManager.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

struct NotificationManager {
    let notificationCenter = UNUserNotificationCenter.current()

    func addLocationEvent(forReminder reminder: Reminder, whenLeaving: Bool) -> UNLocationNotificationTrigger? {
        if let location = reminder.location, let identifier = reminder.identifier, let name = reminder.name {
            
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let area = CLCircularRegion(center: center, radius: 50, identifier: identifier)
            
            switch whenLeaving {
                
            case true:
                print("We will remind you when you leave: \(name)")
                area.notifyOnExit = true
                area.notifyOnEntry = false
            case false:
                print("We will remind you on arrive at: \(name)")
                area.notifyOnExit = false
                area.notifyOnEntry = true
            }
            return UNLocationNotificationTrigger(region: area, repeats: false)
        }
        return nil
    }
    
    func scheduleNewNotification(withReminder reminder: Reminder, locationTrigger trigger: UNLocationNotificationTrigger?) {
        
        if let text = reminder.text, let identifier = reminder.identifier, let notificationTrigger = trigger {
            
            let content = UNMutableNotificationContent()
            content.body = text
            content.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: notificationTrigger)
            
            notificationCenter.add(request)
        }
    }
    
}

