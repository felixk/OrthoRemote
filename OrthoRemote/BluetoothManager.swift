//
//  BluetoothManager.swift
//  OrthoRemote
//
//  Created by Felix Khazin on 5/6/22.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager?
    private var orthoRemote: CBPeripheral?
    private var tx: CBCharacteristic?
    private var rx: CBCharacteristic?
    
    private var counter = 0
    
    func scan() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func disconnectFromDevice () {
        guard let orthoRemote = orthoRemote else {
            return
        }

        centralManager?.cancelPeripheralConnection(orthoRemote)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            let peripherals = centralManager?.retrieveConnectedPeripherals(withServices: [OrthoRemoteUUID.BLEService_UUID])
            
            if let peripherals = peripherals {
                if peripherals.count > 0 {
                    orthoRemote = peripherals[0]
                    orthoRemote?.delegate = self
                    
                    guard let orthoRemote = orthoRemote else { break }
                    
                    centralManager?.connect(orthoRemote, options: nil)
                    break
                }
            }
            
            centralManager?.scanForPeripherals(withServices: [OrthoRemoteUUID.BLEService_UUID])
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
              @unknown default:
            print("Error")
        }
    }

    func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        orthoRemote = peripheral
        orthoRemote?.delegate = self

        print("Peripheral Discovered: \(peripheral)")

        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([OrthoRemoteUUID.BLEService_UUID])
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")

        if error != nil {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        // We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        print("Found \(characteristics.count) characteristics.")

        for characteristic in characteristics {
            if characteristic.uuid.isEqual(OrthoRemoteUUID.BLE_Characteristic_uuid_Rx) {
                rx = characteristic

                peripheral.setNotifyValue(true, for: rx!)
                peripheral.readValue(for: characteristic)
            }

            if characteristic.uuid.isEqual(OrthoRemoteUUID.BLE_Characteristic_uuid_Tx) {
                tx = characteristic

                let relativeRotateCommand = "8080f000207602000200807f".hexadecimal
                
                guard let relativeRotateCommand = relativeRotateCommand, let tx = tx else {
                    return
                }
                
                print("TX Characteristic: \(tx.uuid)")
                
                peripheral.writeValue(relativeRotateCommand,
                                        for: tx,
                                        type: .withoutResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let BUTTON_KEY = 127
        let WHEEL = 0x1
        let clockwise: UInt8 = 0x1
        let counterClockwise: UInt8 = 0x7F
        guard characteristic == rx, let characteristicValue = characteristic.value else { return }

        guard let midiData = MidiData.parseMidiDataPacket(packetData: characteristicValue) else { return }
        
        if(midiData.message == MidiMessage.NoteOn) {
            let key = midiData.data[0] & 0x7F
            
            if(key == BUTTON_KEY) {
                print("button pressed")
            }
        }
        
        if(midiData.message == MidiMessage.NoteOff) {
            let key = midiData.data[0] & 0x7F
            
            if(key == BUTTON_KEY) {
                print("button unpressed")
            }
        }
        
        if(midiData.message == MidiMessage.ControlChange) {
            let key = midiData.data[0] & 0x7F
            
            if(key == WHEEL) {
                let value: UInt8 = midiData.data[1] & 0x7F
                switch(value) {
                case clockwise:
                    counter = counter + 1
                case counterClockwise:
                    counter = counter - 1
                default:
                    break
                }
                
                print("value: \(counter)")
            }
        }
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }
}
