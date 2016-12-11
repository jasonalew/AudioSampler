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

class Sampler: Instrument {
    
    // MARK: - Properties
    var graphSampleRate: Double = 44100.0
    
    var playerUnit: AudioUnit?
    var processingGraph: AUGraph?
    var ioUnit: AudioUnit?
    lazy var sessionInstance = AVAudioSession.sharedInstance()
    
    // MARK: - Init
    init?() {
        do {
            try createAUGraph()
        } catch let error {
            dlog(items: error)
            return nil
        }
        
        do {
            try setupAudioSession()
        } catch let error {
            dlog(items: error)
            return nil
        }
        
        do {
            try configureAndStart(graph: processingGraph!)
        } catch let error {
            dlog(items: error)
            return nil
        }
    }
    
    // MARK: - Setup AUGraph
    func createAUGraph() throws {
        var result = noErr
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
        result = AUGraphNodeInfo(processingGraph, samplerNode, nil, &playerUnit)
        guard result == noErr else {
            throw AudioError.unableToObtainReferenceToSampler(code: Int(result))
        }
        
        // Obtain a reference to the IO Unit
        result = AUGraphNodeInfo(processingGraph, ioNode, nil, &ioUnit)
        guard result == noErr else {
            throw AudioError.unableToObtainReferenceToIOUnit(code: Int(result))
        }
    }
    
    func configureAndStart(graph: AUGraph) throws {
        var result = noErr
        var framesPerSlice: UInt32 = 0
        var framesPerSlicePropertySize = UInt32(MemoryLayout.size(ofValue: framesPerSlice))
        let sampleRatePropertySize = UInt32(MemoryLayout.size(ofValue: graphSampleRate))
        
        guard let ioUnit = ioUnit else {
            throw AudioError.ioUnitError
        }
        // Initialize the IO Unit
        result = AudioUnitInitialize(ioUnit)
        guard result == noErr else {
            throw AudioError.unableToInitializeIOUnit(code: Int(result))
        }
        
        // Set the IO Unit's output sample rate
        result = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &graphSampleRate, sampleRatePropertySize)
        guard result == noErr else {
            throw AudioError.auSetPropertyIOSampleRate(code: Int(result))
        }
        
        // Obtain the value of the maximum frames per slice from the IO Unit 
        result = AudioUnitGetProperty(ioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &framesPerSlice, &framesPerSlicePropertySize)
        guard result == noErr else {
            throw AudioError.unableToRetrieveMaxFramesPerSlice(code: Int(result))
        }
        
        guard let audioUnit = playerUnit else {
            throw AudioError.samplerUnitError
        }
        // Set the sampler unit's output sample rate
        result = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &graphSampleRate, sampleRatePropertySize)
        guard result == noErr else {
            throw AudioError.auSetPropertySamplerSampleRate(code: Int(result))
        }
        
        // Set the sampler unit's maximum frames per slice
        result = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &framesPerSlice, framesPerSlicePropertySize)
        guard result == noErr else {
            throw AudioError.auSetPropertySamplerMaxFramesPerSlice(code: Int(result))
        }
        
        // Initialize the audio processing graph
        result = AUGraphInitialize(graph)
        guard result == noErr else {
            throw AudioError.unableToInitializeAUGraph(code: Int(result))
        }
        
        // Start the graph
        result = AUGraphStart(graph)
        guard result == noErr else {
            throw AudioError.unableToStartAUGraph(code: Int(result))
        }
        
        // Print out the graph to the console
        CAShow(UnsafeMutablePointer<AUGraph>(graph))
    }
    
    func stopAudioProcessingGraph() throws {
        guard let processingGraph = processingGraph else { return }
        let result = AUGraphStop(processingGraph)
        guard result == noErr else {
            throw AudioError.unableToStopAUGraph(code: Int(result))
        }
    }
    
    func restartAudioProcessingGraph() throws {
        guard let processingGraph = processingGraph else { return }
        let result = AUGraphStart(processingGraph)
        guard result == noErr else {
            throw AudioError.unableToRestartAUGraph(code: Int(result))
        }
    }
    
    // MARK: - AudioSession
    func setupAudioSession() throws {
        // Set the category
        do {
            try sessionInstance.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        } catch let error {
            throw AudioSessionError.errorSettingAVAudioSessionCategory(error)
        }
        
        // Set the sample rate
        do {
            try sessionInstance.setPreferredSampleRate(graphSampleRate)
        } catch let error {
            throw AudioSessionError.errorSettingPreferredSampleRate(error)
        }
        
        // Request preferred buffer duration
        do {
            try sessionInstance.setPreferredIOBufferDuration(0.005)
        } catch let error {
            throw AudioSessionError.errorSettingPreferredBufferDuration(error)
        }
        
        // Activate the audio session
        do {
            try sessionInstance.setActive(true)
        } catch let error {
            throw AudioSessionError.errorActivatingSession(error)
        }
        
        // Get the actual hardware sample rate and store it for later use in the graph
        graphSampleRate = sessionInstance.sampleRate
    }
}















