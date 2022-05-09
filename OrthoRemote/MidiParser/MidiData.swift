//
//  MidiData.swift
//  OrthoRemote
//
//  Created by Felix Khazin on 5/5/22.
//
//  Based on https://github.com/happycodelucky/ortho-remote-node

import Foundation

struct MidiData {
    var timestamp: UInt8
    var message: MidiMessage
    var channel: UInt8
    var data: Data
    
    static func parseMidiDataPacket(packetData: Data) -> MidiData? {
        if(packetData.count < 5) {
            return nil
        }
        
        let timestampHigh = packetData[0]
        let timestampLow = packetData[1]
        let status = packetData[2]
        let data = Data(packetData[3...])
        
        let timestamp = (timestampLow & 0x7F) | ((timestampHigh & 0x3F) << 7)
        let message = MidiMessage(rawValue: (status & MidiMessageBitMask))
        let channel = (status & ~MidiMessageBitMask)
        
        guard let message = message else { return nil }
        
        return MidiData(timestamp: timestamp, message: message, channel: channel, data: data)
    }
}
