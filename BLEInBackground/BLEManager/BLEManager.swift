//
//  BLEManager.swift
//  BasweniOS
//
//  Created by lekhnish jha on 17/06/20.
//  Copyright © 2020 Softlabs. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLEParameters
{
    static let BLEThermometerUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    //static let BLEBottleServiceUUID = CBUUID(string: "D751D8FD-CE5E-46E8-BABO-368CCE91B100") // Health Termometer
    //static let BLEBottleServiceUUID = CBUUID(string: "4038708D-7126-44B8-5406-F56F0266A2C7") // iPhone SE
    //static let BLEBottleServiceUUID = CBUUID(string: "C3AB8BE1-BB12-45BB-BC47-CF960AAB4AC5")
    static let BaswenCBCentralRestorationKey = "com.baswen.restorekey.central"
    static let BaswenCBPeripheralRestorationKey = "com.baswen.restorekey.peripheral"
    static let  BLEBottleCharacteristicOneUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    static let  BLEBottleCharacteristicTwoUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

}

struct BLENotifications
{
    static let BluetoothReady = Notification.Name("com.baswen.ble.bluetoothReady")
    static let BluetoothAlreadyReady = Notification.Name("com.baswen.ble.bluetoothAlreadyReady")
    static let BluetoothOff = Notification.Name("com.baswen.ble.bluetoothOff")
    static let BluetoothUnauthorized = Notification.Name("com.baswen.ble.bluetoothUnauthorized")
    static let FoundDevice = Notification.Name("com.baswen.ble.foundDevice")
    static let ScanCompleted = Notification.Name("com.baswen.ble.scanCompleted")
    static let ConnectionComplete = Notification.Name("com.baswen.ble.connectionComplete")
    static let RssiUpdated = Notification.Name("com.baswen.ble.rssiUpdated")
    static let ServiceScanComplete = Notification.Name("com.baswen.ble.serviceScanComplete")
    static let CharacteristicScanComplete = Notification.Name("com.baswen.ble.characteristicScanComplete")
    static let DisconnectedDevice = Notification.Name("com.baswen.ble.disconnectedDevice")
    static let RestoredDevice = Notification.Name("com.baswen.ble.restoredDevice")
    static let characteristicNotified = Notification.Name("com.baswen.ble.characteristicNotified")
}

class BLEManager: NSObject
{
    static let sharedInstance = BLEManager()
    
    var centralManager: CBCentralManager!
    var baswenPeripheral: CBPeripheral!
    var isCentralRestoring: Bool = false
    var restoredCentralIdentifier: String? = nil
    var restoredPeripheralIdentifier: String? = nil
    var pairedBleDevices =  [BLEDevice]()
    var scannedBleDevices =  [BLEDevice]()
    private var isScanning = false
    private let scanTime = 120
    var previousValue: String = ""
    
    var txCharacteristic: CBCharacteristic!
    
    private override init()
    {
        super.init()
    }
    
    func startUpCentralManager() {
        if self.centralManager == nil {
            let serialQueue = DispatchQueue(label: "com.baswen.ble.serialqueue.central")
            
            self.centralManager = CBCentralManager(delegate: self, queue: serialQueue, options: [CBCentralManagerOptionShowPowerAlertKey : false, CBCentralManagerOptionRestoreIdentifierKey : BLEParameters.BaswenCBCentralRestorationKey])
        } else {
            switch self.centralManager.state
            {
            case .poweredOn:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BLENotifications.BluetoothAlreadyReady, object: nil)
                }
                break
                
            case .poweredOff:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BLENotifications.BluetoothOff, object: nil)
                }
                break
                
            case .unauthorized:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BLENotifications.BluetoothUnauthorized, object: nil)
                }
                
            default:
                break
            }
        }
    }
    
    func connectToBLEDevices(bleDevices : [BLEDevice]?) {
        print("BLEManager: connectToBLEDevices -- \(String(describing: bleDevices?.first?.peripheral.name))")
        if self.centralManager != nil {
            var bleDevicesToConnectTo = [BLEDevice]()
            
            if bleDevices != nil {
                bleDevicesToConnectTo = bleDevices!
            }
            else {
                bleDevicesToConnectTo = self.pairedBleDevices
            }
            
            for bleDevice in bleDevicesToConnectTo {
                print("BLEManager: connectToBLEDevices bleDevice -- \(String(describing: bleDevice.peripheral.name))")
                if bleDevice.peripheral.state == .disconnected {
                    bleDevice.shouldAutoReconnectOnDisconnection = true
                    centralManager.connect(bleDevice.peripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey : true, CBConnectPeripheralOptionNotifyOnNotificationKey : true, CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
                }
            }
        }
    }
    
    func disconnectBLEDevices(bleDevices : [BLEDevice]?) {
        guard let devicesToDisconnectFrom = bleDevices else { return }
        print("BLEManager: disconnectBLEDevices -- \(String(describing: bleDevices?.first?.peripheral.name))")
        for device in devicesToDisconnectFrom {
            device.shouldAutoReconnectOnDisconnection = false
            device.peripheral.delegate = nil
            
            if device.peripheral?.state != .disconnected {
                centralManager.cancelPeripheralConnection(device.peripheral)
            }
        }
    }
    
    func linkLossReconnect() {
        print("BLEManager: linkLossReconnect paired devices == \(self.pairedBleDevices)")
        for ble in self.pairedBleDevices {
            if ble.peripheral.state != .connected {
                print("BLEManager: linkLossReconnect lost connection device == \(ble)")
                self.connectToBLEDevices(bleDevices: [ble])
            }
        }
    }
    
    func discoverServices(forBleDevice bleDevice: BLEDevice) {
        print("BLEManager: discoverServices on bleDevice == \(bleDevice)")
        if bleDevice.peripheral.state == .connected {
            print("BLEManager: discoverServices called discover service on == \(bleDevice)")
            //call bleDevice.peripheral to discover service
            bleDevice.peripheral.discoverServices(nil)
            
        }
    }
}

//MARK: BLEManager CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", BLEParameters.BLEThermometerUUID);
            centralManager.scanForPeripherals(withServices: [BLEParameters.BLEThermometerUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        // We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.baswenPeripheral = peripheral
        self.baswenPeripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.baswenPeripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey : true, CBConnectPeripheralOptionNotifyOnNotificationKey : true, CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.baswenPeripheral {
            print("Connected to your Particle Board")
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
         UserNotification.sharedInstance.sendNotification(with: "didDisconnectPeripheral")
        let connectedMatchingBles = self.pairedBleDevices.filter({ (ble) -> Bool in
            return ble.peripheral.identifier.uuidString == peripheral.identifier.uuidString
        })
        
        for bleDevice in connectedMatchingBles {
            
            if bleDevice.shouldAutoReconnectOnDisconnection == true {
                // Connect!
                self.centralManager.connect(bleDevice.peripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey : true, CBConnectPeripheralOptionNotifyOnNotificationKey : true, CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
                // on disconnect we'll reissue the connect command (even if the app goes out of range)
                // This should force iOS to relaunch our app (if it's is suspended or terminated mode) in the background and call the willRestoreState: method handled in this class
            }
            else {
                if let index = self.pairedBleDevices.firstIndex(of: bleDevice) {
                    self.pairedBleDevices.remove(at: index)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        self.isCentralRestoring = true
        
        UserNotification.sharedInstance.sendNotification(with: "willRestoreState")
        
        if let restoredPeripherals =  dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]
        {
            if restoredPeripherals.count > 0
            {
                for restoredPeripheral in restoredPeripherals
                {
                    let connectedMatchingBles = self.pairedBleDevices.filter({ (ble) -> Bool in
                        return ble.peripheral.identifier.uuidString == restoredPeripheral.identifier.uuidString
                    })
                    
                    if connectedMatchingBles.count == 0
                    {
                        let bleDevice = BLEDevice()
                        bleDevice.peripheral = restoredPeripheral
                        bleDevice.peripheral.delegate = self
                        bleDevice.shouldAutoReconnectOnDisconnection = true
                        
                        self.pairedBleDevices.append(bleDevice)
                    }
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager didFailToConnect peripheral ")
    }
}

//MARK: BLEManager CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard  let services = peripheral.services else {
            print("CBPeripheralDelegate: peripheral didDiscoverServices didn't find services")
            return
        }
        
        for service in services {
            print("CBPeripheralDelegate: peripheral didDiscoverServices === \(service)")
            peripheral.discoverCharacteristics([BLEParameters.BLEBottleCharacteristicOneUUID, BLEParameters.BLEBottleCharacteristicTwoUUID], for: service)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        guard let characteristics = service.characteristics else {
            print("CBPeripheralDelegate: peripheral not find characteristics For === \(service)")
            return
        }
        
        for characteristic in characteristics {
            print("characteristic found for service === \(service)\n  characteristic == \(characteristic)")
            
            if characteristic.uuid == BLEParameters.BLEBottleCharacteristicTwoUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        self.txCharacteristic = characteristics[0]
        
        self.activatePeripheralForCount(peripheral: peripheral, charecteristic: characteristics[0])

    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let errorStr = error == nil ? "with no error" : "with error - \(String(describing: error?.localizedDescription))"
        print("CBPeripheralDelegate: peripheral didReadRSSI \(errorStr)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        let errorStr = error == nil ? "with no error" : "with error - \(String(describing: error?.localizedDescription))"
        
        print("CBPeripheralDelegate: \(errorStr)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let temperatureData = characteristic.value else {
            return
        }
        
        if let tempString = NSString.init(data: temperatureData, encoding: String.Encoding.utf8.rawValue) as String?, tempString != "" {
            if previousValue != tempString {
                previousValue = tempString
                UserDefaults.standard.set(previousValue, forKey: "characteristic")
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BLENotifications.characteristicNotified, object: self.previousValue)
                }
                UserNotification.sharedInstance.sendNotification(with: previousValue)
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//            self.activatePeripheralForCount(peripheral: peripheral, charecteristic: self.txCharacteristic)
//        })
        
    }
}

extension BLEManager {
    func stringToBytes(_ hexString: String) -> [UInt8]? {
        let length = hexString.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = hexString.startIndex
        for _ in 0..<length/2 {
            let nextIndex = hexString.index(index, offsetBy: 2)
            if let b = UInt8(hexString[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    func activatePeripheralForCount(peripheral : CBPeripheral, charecteristic: CBCharacteristic) {
        if peripheral.state == CBPeripheralState.connected {
            let value = self.stringToBytes("2a02")
            
            let data = NSData(bytes: value, length: 2)
            
            peripheral.writeValue(data as Data, for: charecteristic, type: CBCharacteristicWriteType.withResponse)
            
        }
    }
}
