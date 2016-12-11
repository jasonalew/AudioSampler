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
    var sampler: Instrument!
    override func viewDidLoad() {
        super.viewDidLoad()

        sampler = Sampler()!
        let instrumentUrl = Bundle.main.url(forResource: "ontology-destroy-you-bass", withExtension: "exs")
        try! sampler.loadInstrument(from: instrumentUrl!, patch: 0, type: InstrumentType.exs)
    }

    @IBAction func buttonTapped(_ sender: Any) {
        sampler.play(note: 60, velocity: 127)
    }
    
}
