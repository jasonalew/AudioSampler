//
//  MIDIEventCapable.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import AVFoundation

enum MidiMessage {
    static let noteOn: UInt32 = 0x9
    static let noteOff: UInt32 = 0x8
}

protocol MIDIEventCapable {}

extension MIDIEventCapable {
    // MARK: - Note Commands
    func play(note: UInt32, velocity: UInt32, with sampler: AudioUnit) {
        let newVelocity = min(velocity, 127)
        let noteCommand = MidiMessage.noteOn << 4 | 0
        let result = MusicDeviceMIDIEvent(sampler, noteCommand, note, newVelocity, 0)
        if result != noErr {
            dlog(items: "Unable to play note. Error code: \(Int(result))")
        }
    }
    
    func stop(note: UInt32, on sampler: AudioUnit) {
        let noteCommand = MidiMessage.noteOff << 4 | 0
        let result = MusicDeviceMIDIEvent(sampler, noteCommand, note, 0, 0)
        if result != noErr {
            dlog(items: "Unable to stop playing the note. Error code: \(Int(result))")
        }
    }
}
