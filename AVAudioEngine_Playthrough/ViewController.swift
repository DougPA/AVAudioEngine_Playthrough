//
//  ViewController.swift
//  AVAudioEngine_Playthrough
//
//  Created by Douglas Adams on 7/21/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

  var engine = AVAudioEngine()
  

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  @IBAction func play(_ sender: NSButton) {

//    let format = AVAudioFormat(standardFormatWithSampleRate: 48_000.0, channels: 2)
    
    engine.connect(engine.inputNode, to: engine.mainMixerNode, format: engine.inputNode.inputFormat(forBus: 0))
    
    // Start engine
    do {
      try engine.start()
    }
    catch {
      print("oh no!")
    }
  }
}

