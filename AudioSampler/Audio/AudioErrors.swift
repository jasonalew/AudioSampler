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
    case unableToAddSamplerToGraph(code: Int)
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
}
