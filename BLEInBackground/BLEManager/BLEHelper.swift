//
//  BLEHelper.swift
//  BasweniOS
//
//  Created by lekhnish jha on 17/06/20.
//  Copyright © 2020 Softlabs. All rights reserved.
//

import Foundation

class BLEHelper {
    
    static func getMACAddress(manufData: String) -> String {
        
        //extraction of macaddress from hexstring
        let macAddStartIndex6 = manufData.index(manufData.startIndex, offsetBy: 4)
        let macAddEndIndex6 = manufData.index(manufData.startIndex, offsetBy: 6)
        let macRange6 = macAddStartIndex6..<macAddEndIndex6
        let maccAddressStr6 = manufData[macRange6]
        
        let macAddStartIndex5 = manufData.index(manufData.startIndex, offsetBy: 6)
        let macAddEndIndex5 = manufData.index(manufData.startIndex, offsetBy: 8)
        let macRange5 = macAddStartIndex5..<macAddEndIndex5
        let maccAddressStr5 = manufData[macRange5]
        
        let macAddStartIndex4 = manufData.index(manufData.startIndex, offsetBy: 8)
        let macAddEndIndex4 = manufData.index(manufData.startIndex, offsetBy: 10)
        let macRange4 = macAddStartIndex4..<macAddEndIndex4
        let maccAddressStr4 = manufData[macRange4]
        
        let macAddStartIndex3 = manufData.index(manufData.startIndex, offsetBy: 10)
        let macAddEndIndex3 = manufData.index(manufData.startIndex, offsetBy: 12)
        let macRange3 = macAddStartIndex3..<macAddEndIndex3
        let maccAddressStr3 = manufData[macRange3]
        
        let macAddStartIndex2 = manufData.index(manufData.startIndex, offsetBy: 12)
        let macAddEndIndex2 = manufData.index(manufData.startIndex, offsetBy: 14)
        let macRange2 = macAddStartIndex2..<macAddEndIndex2
        let maccAddressStr2 = manufData[macRange2]
        
        let macAddStartIndex1 = manufData.index(manufData.startIndex, offsetBy: 14)
        let macAddEndIndex1 = manufData.index(manufData.startIndex, offsetBy: 16)
        let macRange1 = macAddStartIndex1..<macAddEndIndex1
        let maccAddressStr1 = manufData[macRange1]
        
        let macAdd1 = maccAddressStr1 + maccAddressStr2 + maccAddressStr3
        
        let macAdd2 = maccAddressStr4 + maccAddressStr5 + maccAddressStr6
        
        return String(macAdd1 + macAdd2)
    }

}
