//
//  AppDelegate.swift
//  BLEInBackground
//
//  Created by lekhnish jha on 20/06/20.
//  Copyright © 2020 lekhnish jha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if granted {
                print("granted permission")
            }
        }
        return true
    }
    
    func handleLaunchOptionsIfAny(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let options = launchOptions {
            if let centralManagerIdentifiers = options[UIApplication.LaunchOptionsKey.bluetoothCentrals] as? [String] {
                UserNotification.sharedInstance.sendNotification(with: "LaunchOptionsKey")
                let filteredIdentifiers = centralManagerIdentifiers.filter({ (identifier) -> Bool in
                    return identifier == BLEParameters.BaswenCBCentralRestorationKey
                })
                
                if filteredIdentifiers.count > 0 {
                    BLEManager.sharedInstance.restoredCentralIdentifier = filteredIdentifiers[0]
                    BLEManager.sharedInstance.startUpCentralManager()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
      return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
      return true
    }
}

