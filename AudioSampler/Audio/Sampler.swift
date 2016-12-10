//
//  Sampler.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class Sampler: NSObject {
    enum MidiMessage {
        static let noteOn = 0x9
        static let noteOff = 0x8
    }
    
    let preferredSampleRate = 44100.0
    
    var samplerUnit: AudioUnit?
    var processingGraph: AUGraph?
    var ioUnit: AudioUnit?
    
    override init() {
        super.init()
        do {
            try createAUGraph()
        } catch let error {
            dlog(items: error)
        }
    }
    
    func createAUGraph() throws {
        var result: OSStatus = noErr
        var samplerNode = AUNode()
        var ioNode = AUNode()
        
        var samplerDescription = AudioComponentDescription(
            componentType: kAudioUnitType_MusicDevice,
            componentSubType: kAudioUnitSubType_Sampler,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var ioUnitDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_RemoteIO,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        // Instantiate an audio processing graph
        result = NewAUGraph(&processingGraph)
        guard let processingGraph = processingGraph,
            result == noErr else {
            throw AudioError.unableToCreateAUGraph(code: Int(result))
        }
        
        // Add the sampler to the graph
        result = AUGraphAddNode(processingGraph, &samplerDescription, &samplerNode)
        guard result == noErr else {
            throw AudioError.unableToAddSamplerToGraph(code: Int(result))
        }
        
        // Add the output unit to the graph
        result = AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode)
        guard result == noErr else {
            throw AudioError.unableToAddOutputToGraph(code: Int(result))
        }
        
        // Open the graph
        result = AUGraphOpen(processingGraph)
        guard result == noErr else {
            throw AudioError.unableToOpenGraph(code: Int(result))
        }
        
        // Connect the sampler unit to the output unit
        result = AUGraphConnectNodeInput(processingGraph, samplerNode, 0, ioNode, 0)
        guard result == noErr else {
            throw AudioError.unableToInterconnectNodesInGraph(code: Int(result))
        }
        
        // Obtain a reference to the sampler unit from its node
        result = AUGraphNodeInfo(processingGraph, samplerNode, nil, &samplerUnit)
        guard result == noErr else {
            throw AudioError.unableToObtainReferenceToSampler(code: Int(result))
        }
        
        // Obtain a reference to the IO Unit
        result = AUGraphNodeInfo(processingGraph, ioNode, nil, &ioUnit)
        guard result == noErr else {
            throw AudioError.unableToObtainReferenceToIOUnit(code: Int(result))
        }
    }
    
    func configureAndStart(graph: AUGraph) {
        
    }
}














