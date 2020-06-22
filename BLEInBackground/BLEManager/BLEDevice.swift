//
//  BLEDevice.swift
//  BasweniOS
//
//  Created by lekhnish jha on 17/06/20.
//  Copyright © 2020 Softlabs. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BatteryStatus : Int
{
    case low = 65
    case medium = 66
    case high = 67
}

class BLEDevice: NSObject
{
    var peripheral : CBPeripheral!
    var advertisementData : [String: Any]?
    var bleRSSI : Int? = nil
    var bleBatteryLevel : BatteryStatus? = nil
    var characteristic : CBCharacteristic? = nil
    var shouldAutoReconnectOnDisconnection: Bool = true
}
