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

extension MIDIEventCapable where Self: Instrument {
    // MARK: - Note Commands
    
    /// Plays a MIDI note
    ///
    /// - Parameters:
    ///   - note: the note to play
    ///   - velocity: velocity in range 0-127
    func play(note: UInt32, velocity: UInt32) {
        let newVelocity = min(velocity, 127)
        let noteCommand = MidiMessage.noteOn << 4 | 0
        guard let instrumentUnit = self.instrumentUnit else { return }
        let result = MusicDeviceMIDIEvent(instrumentUnit, noteCommand, note, newVelocity, 0)
        if result != noErr {
            dlog(items: "Unable to play note. Error code: \(Int(result))")
        }
    }
    
    /// Stops playing a MIDI note
    ///
    /// - Parameter note: the note to stop
    func stop(note: UInt32) {
        guard let instrumentUnit = self.instrumentUnit else { return }
        let noteCommand = MidiMessage.noteOff << 4 | 0
        let result = MusicDeviceMIDIEvent(instrumentUnit, noteCommand, note, 0, 0)
        if result != noErr {
            dlog(items: "Unable to stop playing the note. Error code: \(Int(result))")
        }
    }
}
