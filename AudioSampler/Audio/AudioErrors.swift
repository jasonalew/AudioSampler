//
//  AudioErrors.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

enum AudioError: Error {
    case unableToCreateAUGraph(code: Int)
    case unableToAccessGraph
    case unableToAddNodeToGraph(code: Int)
    case unableToAddOutputToGraph(code: Int)
    case unableToOpenGraph(code: Int)
    case unableToInterconnectNodesInGraph(code: Int)
    case unableToObtainReferenceToSampler(code: Int)
    case unableToObtainReferenceToIOUnit(code: Int)
    case unableToInitializeIOUnit(code: Int)
    case auSetPropertyIOSampleRate(code: Int)
    case auSetPropertySamplerSampleRate(code: Int)
    case auSetPropertySamplerMaxFramesPerSlice(code: Int)
    case unableToRetrieveMaxFramesPerSlice(code: Int)
    case unableToInitializeAUGraph(code: Int)
    case unableToStartAUGraph(code: Int)
    case unableToStopAUGraph(code: Int)
    case unableToRestartAUGraph(code: Int)
    case ioUnitError
    case samplerUnitError
    // Instrument loading
    case unableToSetPresetProperty(code: Int)
}

enum AudioSessionError: Error {
    case errorSettingAVAudioSessionCategory(Error)
    case errorSettingPreferredSampleRate(Error)
    case errorSettingPreferredBufferDuration(Error)
    case errorActivatingSession(Error)
}

enum MusicPlayerError: Error {
    case unableToCreateNewPlayer(code: Int)
    case unableToCreateNewSequence(code: Int)
    case unableToSetSequence(code: Int)
    case unableToSetAUGraphForSequence(code: Int)
    case unableToStartPreroll(code: Int)
    case unableToAccessPlayerOrSequence
    case unableToLoadFile(code: Int)
    case unableToGetTempoTrack(code: Int)
}
