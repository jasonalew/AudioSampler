//
//  MidiPlayer.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import AVFoundation

class MidiPlayer {
    // MARK: - Properties
    var musicPlayer: MusicPlayer?
    var musicSequence: MusicSequence?
    var tempo: Float64 = 100.0 { // in BPMs
        didSet {
            set(tempo: tempo)
        }
    }
    private var tempoTrack: MusicTrack?
    
    // MARK: - Init
    init() throws {
        var result = noErr
        result = NewMusicPlayer(&musicPlayer)
        guard result == noErr else {
            throw MusicPlayerError.unableToCreateNewPlayer(code: Int(result))
        }
        
        result = NewMusicSequence(&musicSequence)
        guard result == noErr else {
            throw MusicPlayerError.unableToCreateNewSequence(code: Int(result))
        }
    }
    
    // MARK: - Actions
    /// Loads a MIDI sequence
    ///
    /// - Parameters:
    ///   - url: the URL of the MIDI file
    ///   - graph: the AUGraph
    /// - Throws: throws a MusicPlayerError
    func loadMidiSequence(at url: URL, withGraph graph: AUGraph) throws {
        var result = noErr
        guard let musicSequence = musicSequence,
            let musicPlayer = musicPlayer else {
                throw MusicPlayerError.unableToAccessPlayerOrSequence
        }
        
        // Load the file
        result = MusicSequenceFileLoad(musicSequence,
                                       url as CFURL,
                                       MusicSequenceFileTypeID.midiType, [])
        guard result == noErr else {
            throw MusicPlayerError.unableToLoadFile(code: Int(result))
        }
        
        // Set the sequence
        result = MusicPlayerSetSequence(musicPlayer, musicSequence)
        guard result == noErr else {
            throw MusicPlayerError.unableToSetSequence(code: Int(result))
        }
        
        // Set the AUGraph
        result = MusicSequenceSetAUGraph(musicSequence, graph)
        guard result == noErr else {
            throw MusicPlayerError.unableToSetAUGraphForSequence(code: Int(result))
        }
        
        // Preroll to prevent lag on play
        result = MusicPlayerPreroll(musicPlayer)
        guard result == noErr else {
            throw MusicPlayerError.unableToStartPreroll(code: Int(result))
        }
        
        // Get the tempo track
        result = MusicSequenceGetTempoTrack(musicSequence, &tempoTrack)
        guard result == noErr else {
            throw MusicPlayerError.unableToGetTempoTrack(code: Int(result))
        }
        
    }
    
    func play() {
        guard let musicPlayer = musicPlayer else { return }
        var result = noErr
        result = MusicPlayerStart(musicPlayer)
        if result != noErr {
            dlog(items: "Can't start player. Error: \(Int(result))")
        }
    }
    
    func pause() {
        stop(reset: false)
    }
    
    func stop(reset: Bool = true) {
        guard let musicPlayer = musicPlayer else { return }
        var result = noErr
        result = MusicPlayerStop(musicPlayer)
        if result != noErr {
            dlog(items: "Unable to stop player. Error: \(Int(result))")
        }
        if reset {
            MusicPlayerSetTime(musicPlayer, 0)
        }
    }
    
    /// Set the tempo for the sequence
    ///
    /// - Parameter tempo: beats per minute
    func set(tempo: Float64) {
        guard let tempoTrack = tempoTrack else { return }
        removeTempoEvents(from: tempoTrack)
        var result = noErr
        result = MusicTrackNewExtendedTempoEvent(tempoTrack, 0, tempo)
        if result != noErr {
            dlog(items: "Unable to set tempo. Error: \(Int(result))")
        }
    }
    
    /// Removes the tempo events
    ///
    /// - Parameter track: the tempo track to remove events from
    private func removeTempoEvents(from track: MusicTrack) {
        // Create a new iterator
        var iterator: MusicEventIterator?
        NewMusicEventIterator(track, &iterator)
        // Prepare the iterator properties
        var hasNext: DarwinBoolean = true
        var timeStamp: MusicTimeStamp = 0
        var eventType: MusicEventType = 0
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0
        
        // Check if there is an event and loop
        guard let itr = iterator else { return }
        MusicEventIteratorHasCurrentEvent(itr, &hasNext)
        while hasNext.boolValue {
            MusicEventIteratorGetEventInfo(itr,
                                           &timeStamp,
                                           &eventType,
                                           &eventData,
                                           &eventDataSize)
            // Delete the tempo event
            if eventType == kMusicEventType_ExtendedTempo {
                MusicEventIteratorDeleteEvent(itr)
            } else {
                MusicEventIteratorNextEvent(itr)
            }
            MusicEventIteratorHasCurrentEvent(itr, &hasNext)
        }
        DisposeMusicEventIterator(itr)
    }
}










