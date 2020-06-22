//
//  UserNotification.swift
//  BLEInBackground
//
//  Created by lekhnish jha on 20/06/20.
//  Copyright © 2020 lekhnish jha. All rights reserved.
//

import Foundation
import UIKit

class UserNotification: NSObject {
    
    static let sharedInstance = UserNotification()
    
    private override init() {
        super.init()
    }
    
    func sendNotification(with pillsCount: String) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()
        
        center.delegate = self
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Lekhnish"
        content.subtitle = "Pills"
        content.body = "remaining pills = " + pillsCount
        content.sound = UNNotificationSound.default
        
        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:1.0, repeats: false)
        
        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
        
    }
}

extension UserNotification: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {                     completionHandler([.alert, .sound, .badge])
    }
}
