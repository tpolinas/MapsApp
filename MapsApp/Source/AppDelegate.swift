//
//  AppDelegate.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            if granted {
                let trigger = self.makeIntervalNotificationTrigger()
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(trigger) { (error) in
                    if error != nil {
                        // Handle any errors.
                    }
                }
                if let error {
                    print(error)
                }
            }
        }
        return true
    }
        
        
        func makeNotificationContent() -> UNNotificationContent {
            let content = UNMutableNotificationContent()
            content.title = "Hey!"
            content.subtitle = "You haven't been there for 30 minutes!"
            content.body = "Come in to check what happened while you were away!"
            content.badge = 1
            
            return content
        }
        
        func makeIntervalNotificationTrigger() -> UNNotificationRequest {
            let date = Date.now + 1800
            let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: makeNotificationContent(), trigger: trigger)
            
            return request
        }
        
        // MARK: UISceneSession Lifecycle
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
        
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
        
}

