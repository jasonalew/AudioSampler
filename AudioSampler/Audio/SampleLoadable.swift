//
//  SampleLoadable.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import AVFoundation

protocol SampleLoadable {}

extension SampleLoadable where Self: AudioType {
    /// Loads and instrument to the AudioUnit sampler
    ///
    /// - Parameters:
    ///   - sampler: the AudioUnit sampler
    ///   - url: URL of the sample
    ///   - patch: the preset number
    ///   - type: a SF2, EXS, or AUPreset instrument
    func loadInstrument(from url: URL, patch: Int, type: Int) throws {
        
        var result = noErr
        var instrumentData = AUSamplerInstrumentData(
            fileURL: Unmanaged.passUnretained(url as CFURL),
            instrumentType: UInt8(type),
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB),
            presetID: UInt8(patch))
        
        // Load the instrument
        guard let playerUnit = self.playerUnit else {
            throw AudioError.samplerUnitError
        }
        result = AudioUnitSetProperty(
            playerUnit,
            kAUSamplerProperty_LoadInstrument,
            kAudioUnitScope_Global,
            0,
            &instrumentData,
            UInt32(MemoryLayout.size(ofValue: instrumentData)))
        guard result == noErr else {
            throw AudioError.unableToSetPresetProperty(code: Int(result))
        }
    }
}
