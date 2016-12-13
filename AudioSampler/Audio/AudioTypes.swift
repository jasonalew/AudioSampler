//
//  AudioTypes.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import AVFoundation

/// The type of sound bank to load
enum InstrumentType {
    static let sf2 = kInstrumentType_SF2Preset
    static let exs = kInstrumentType_EXS24
    static let auPreset = kInstrumentType_AUPreset
}

protocol AudioType {
    var instrumentUnit: AudioUnit? { get set }
    var processingGraph: AUGraph? { get set }
}

typealias Instrument = AudioType & MIDIEventCapable
typealias SamplerInstrument = Instrument & SampleLoadable
