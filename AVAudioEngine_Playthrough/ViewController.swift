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
  
  var inputDevices = AudioHelper.inputDevices
  var outputDevices = AudioHelper.outputDevices

  @IBAction func play(_ sender: NSButton) {

    for dev in inputDevices {
      Swift.print("Input  deviceID = \(dev.id)")
    }
    for dev in outputDevices {
      Swift.print("Output deviceID = \(dev.id)")
    }
    
    engine.connect(engine.inputNode, to: engine.mainMixerNode, format: engine.inputNode.inputFormat(forBus: 0))
    
    // Start engine
    do {
      try engine.start()
    }
    catch {
      print("Failed to start AVAudioEngine")
    }
  }

  @IBAction func pause(_ sender: NSButton) {
  
    engine.pause()
  }
  
  @IBAction func stop(_ sender: NSButton) {
  
    engine.stop()
  }
  
  @IBAction func volume(_ sender: NSSlider) {
  
    engine.inputNode.volume = sender.floatValue
  }
  
  @IBAction func pan(_ sender: NSSlider) {
  
    engine.inputNode.pan = sender.floatValue
  }

//  func changeDefaultInput(to device: AudioDevice) {
//
//    let inputNode: AVAudioInputNode = engine.inputNode
//    // get the low level input audio unit from the engine:
//    guard let inputUnit: AudioUnit = inputNode.audioUnit else { fatalError() }
//
//    Swift.print("Change to DeviceID = \(device.id)")
//
//    // use core audio low level call to set the input device:
//    var inputDeviceID: AudioDeviceID = device.id
//    AudioUnitSetProperty(inputUnit,
//                         kAudioOutputUnitProperty_CurrentDevice,
//                         kAudioUnitScope_Global,
//                         0,
//                         &inputDeviceID,
//                         UInt32(MemoryLayout<AudioDeviceID>.size))
//
//    let error = AudioUnitSetProperty(inputUnit,
//                                     kAudioOutputUnitProperty_CurrentDevice,
//                                     kAudioUnitScope_Global,
//                                     0,
//                                     &inputDeviceID,
//                                     UInt32(MemoryLayout<AudioDeviceID>.size))
//    Swift.print("error = \(error)")
//  }
}

