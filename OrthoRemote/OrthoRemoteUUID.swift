//
//  OrthoRemoteUUID.swift
//  OrthoRemote
//
//  Created by Felix Khazin on 5/6/22.
//

import Foundation
import CoreBluetooth

struct OrthoRemoteUUID {
    static let kBLEService_UUID = "03B80E5A-EDE8-4B33-A751-6CE34EC4C700"
    static let kBLE_Characteristic_uuid_Tx = "7772E5DB-3868-4112-A1A9-F2669D106BF3"
    static let kBLE_Characteristic_uuid_Rx = "7772E5DB-3868-4112-A1A9-F2669D106BF3"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx) // (Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx) // (Property = Read/Notify)
}
