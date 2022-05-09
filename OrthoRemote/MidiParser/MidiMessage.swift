//
//  MidiMessage.swift
//  OrthoRemote
//
//  Created by Felix Khazin on 5/5/22.
//
//  Based on https://github.com/happycodelucky/ortho-remote-node

import Foundation

enum MidiMessage: UInt8 {
    case NoteOff             = 128
    case NoteOn              = 144
    case PolyKeyPressure     = 160
    case ControlChange       = 176
    case ProgramChange       = 192
    case ChannelPressure     = 208
    case PitchBand           = 224
    case SysEx               = 240
}

let MidiMessageBitMask: UInt8 = 0b1111 << 4
