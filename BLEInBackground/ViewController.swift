//
//  ViewController.swift
//  BLEInBackground
//
//  Created by lekhnish jha on 20/06/20.
//  Copyright © 2020 lekhnish jha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var notificationObservers = [NSObjectProtocol]()
    @IBOutlet  weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //BLEManager handling
        
        if let tempData = UserDefaults.standard.string(forKey: "characteristic") {
            label.text = "Pills count === \(String(describing: tempData))"
        }
        
        self.setupBleNotificationHandlers()
        
        if BLEManager.sharedInstance.restoredCentralIdentifier != nil {
            // restored instantiation
            BLEManager.sharedInstance.restoredCentralIdentifier = nil
        }
        else {
            // normal instantiation
            BLEManager.sharedInstance.startUpCentralManager()
        }
        BLEManager.sharedInstance.linkLossReconnect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Clear all observers
        for observer in self.notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.notificationObservers.removeAll()
    }

}

extension ViewController {
    func startScanning() {
        print("BottlesListViewController: startScanning")
    }
}

// MARK: BLEManager Notification Handler
extension ViewController {
    func setupBleNotificationHandlers() {
        self.notificationObservers.removeAll()
        
        var observer = NotificationCenter.default.addObserver(forName: BLENotifications.BluetoothAlreadyReady, object: nil, queue: OperationQueue.main) { (notification) in
            print("BottlesListViewController: blueTooth Powered on called")
            // try to retrieve tagged peripherals by using their ble uuid
            // if there're still some tags with peripherals missing, use the discover devices option
        }
        
        self.notificationObservers.append(observer)
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.BluetoothReady, object: nil, queue: OperationQueue.main) { (notification) in
            print("BottlesListViewController: BluetoothReady event called")
            // try to retrieve tagged peripherals by using their ble uuid
            // if there're still some tags with peripherals missing, use the discover devices option
        }
        
        self.notificationObservers.append(observer)
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.BluetoothUnauthorized, object: nil, queue: OperationQueue.main) { (notification) in
            print("BottlesListViewController: BluetoothUnauthorized event called")
            //Show unauthorized device alert
        }
        
        self.notificationObservers.append(observer)
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.ScanCompleted, object: nil, queue: OperationQueue.main) { (notification) in
            
            let scannedBles = BLEManager.sharedInstance.scannedBleDevices
            
            print("NotificationCenter BLENotifications.ScanCompleted \(scannedBles)")
            
        }
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.FoundDevice, object: nil, queue: OperationQueue.main) { (notification) in
            print("NotificationCenter BLENotifications.FoundDevice notification")
        }
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.BluetoothOff, object: nil, queue: OperationQueue.main) { (notification) in
            
            let alert = UIAlertController(title: "Warning!", message: "Bluetooth is power off! Please turn it on in order to scan devices", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            let noAction = UIAlertAction(title: "No", style: .destructive) { (_) in
                self.navigationController?.popViewController(animated: true)
                
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.ConnectionComplete, object: nil, queue: OperationQueue.main) { (notification) in
            print("BottlesListViewController: Bluetooth ConnectionComplete event called")
        }
        
        self.notificationObservers.append(observer)
        
        observer = NotificationCenter.default.addObserver(forName: BLENotifications.characteristicNotified, object: nil, queue: OperationQueue.main) { (notification) in
            if let text = notification.object as? String {
                self.label.text = "Pills count === \(text))"
            }
            
        }
        
        self.notificationObservers.append(observer)
    }
}

