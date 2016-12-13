//
//  ViewController.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK: - Properties
    var sampler: SamplerInstrument!
    var midiPlayer: MidiPlayer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSampler()
        setupMidiPlayer()
    }

    // MARK: - Actions
    func setupSampler() {
        sampler = Sampler()
        guard let instrumentUrl = Bundle.main.url(forResource: "ElPiano1",
                                                  withExtension: "sf2") else { return }
        do {
            try sampler.loadInstrument(from: instrumentUrl, patch: 0, type: InstrumentType.sf2)
        } catch let error {
            dlog(items: error)
            return
        }
    }
    
    func setupMidiPlayer() {
        do {
            try midiPlayer = MidiPlayer()
        } catch let error {
            dlog(items: error)
            return
        }
        guard let midiUrl = Bundle.main.url(forResource: "bach-invention-01",
                                            withExtension: "mid"),
        let processingGraph = sampler.processingGraph else { return }
        do {
            try midiPlayer.loadMidiSequence(at: midiUrl, withGraph: processingGraph)
            let tempo: Float64 = 74
            updateTempo(tempo)
            tempoSlider.value = Float(tempo)
        } catch let error {
            dlog(items: error)
            return
        }
    }
    
    func updateTempo(_ tempo: Float64) {
        midiPlayer.tempo = tempo
        bpmLabel.text = "\(Int(tempo)) bpm"
    }
    
    // MARK: - IBActions
    @IBAction func buttonTapped(_ sender: Any) {
        sampler.play(note: 60, velocity: 127)
    }
    
    @IBAction func playSequence(_ sender: Any) {
        midiPlayer.play()
    }
    
    @IBAction func stopSequence(_ sender: Any) {
        midiPlayer.stop()
    }
    
    @IBAction func pauseSequence(_ sender: Any) {
        midiPlayer.pause()
    }
    
    @IBAction func bpmChanged(_ sender: UISlider) {
        let tempo = Float64(sender.value)
        updateTempo(tempo)
    }
}
