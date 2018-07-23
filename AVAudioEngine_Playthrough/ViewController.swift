//
//  ViewController.swift
//  AVAudioEngine_Playthrough
//
//  Created by Douglas Adams on 7/21/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController                        : NSViewController {

  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  @objc dynamic var inputs                  : [String] { return inputDevices.map  { $0.name! } }
  @objc dynamic var outputs                 : [String] { return outputDevices.map { $0.name! } }

  var inputDevices = AudioHelper.inputDevices
  var outputDevices = AudioHelper.outputDevices

  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  @IBOutlet private weak var inputPopup     : NSPopUpButton!
  @IBOutlet private weak var outputPopup    : NSPopUpButton!
  
  private var engine                        : AVAudioEngine?

  // ------------------------------------------------------------------------------
  // MARK: - Action methods
  
  @IBAction func play(_ sender: NSButton) {
    
    // get the selected input & output devices
    let inputDeviceIndex = inputPopup.indexOfSelectedItem
    let outputDeviceIndex = outputPopup.indexOfSelectedItem

    // make the selections the default input & output devices
    if !AudioHelper.setDefaultDevice(inputDevices[inputDeviceIndex].id, .input) { Swift.print("Could not set input device = \(inputs[inputDeviceIndex])") }
    if !AudioHelper.setDefaultDevice(outputDevices[outputDeviceIndex].id, .output) { Swift.print("Could not set output device = \(outputs[outputDeviceIndex])") }
    
    // create the engine
    engine = AVAudioEngine()
    
    // connect the input to the mixer (output is implicit)
    engine!.connect(engine!.inputNode, to: engine!.mainMixerNode, format: engine!.inputNode.inputFormat(forBus: 0))
    
    // Start engine
    do {
      try engine!.start()
    }
    catch {
      print("Failed to start AVAudioEngine")
    }
  }

  @IBAction func pause(_ sender: NSButton) {
  
    engine?.pause()
  }
  
  @IBAction func stop(_ sender: NSButton) {
  
    engine?.stop()
    engine = nil
  }
  
  @IBAction func volume(_ sender: NSSlider) {
  
    engine?.inputNode.volume = sender.floatValue
  }
  
  @IBAction func pan(_ sender: NSSlider) {
  
    engine?.inputNode.pan = sender.floatValue
  }
}

