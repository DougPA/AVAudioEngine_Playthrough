//
//  AudioHelper.swift
//  AVAudioEngine_Playthrough
//
//  Created by Douglas Adams on 7/21/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Foundation
import CoreAudio
import AudioUnit
import AudioToolbox

// ------------------------------------------------------------------------------
// MARK: - AudioHelper Class implementation
// ------------------------------------------------------------------------------

public typealias DeviceID = UInt32

public final class AudioHelper {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static properties
  
  public static let kInput = true
  public static let kOutput = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum Direction: String {
    case input = "Input"
    case output = "Output"
  }
  
  public static var defaultInputDevice      : AudioDeviceID { return getDefaultDevice(for: .input) }
  public static var defaultOutputDevice     : AudioDeviceID { return getDefaultDevice(for: .output) }
  public static var inputDevices            : [AudioDevice] { return getDeviceList(for: .input) }
  public static var outputDevices           : [AudioDevice] { return getDeviceList(for: .output) }
  
  public final class func audioDeviceId(for audioUnit: AudioUnit) -> AudioDeviceID? {
    
    var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var deviceID = AudioDeviceID()
    AudioUnitGetProperty(audioUnit, kAudioOutputUnitProperty_CurrentDevice,
                         kAudioUnitScope_Global, 0, &deviceID, &dataSize)
    
    return deviceID
  }
  // ----------------------------------------------------------------------------
  // MARK: - Private class methods
  
  /// Find the default device for the specified direction
  ///
  /// - Parameter direction:    Input / Output
  /// - Returns:                a device ID
  ///
  private final class func getDefaultDevice(for direction: Direction) -> AudioDeviceID {
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    var deviceID : UInt32 = 0
    var property = AudioObjectPropertyAddress(mSelector: direction == .input ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
                                              mScope: kAudioObjectPropertyScopeGlobal,
                                              mElement: kAudioObjectPropertyElementMaster)
    // get the default device
    guard AudioObjectGetPropertyData( AudioObjectID(kAudioObjectSystemObject), &property, 0, nil, &size, &deviceID ) == noErr else { fatalError() }
    
    return deviceID
  }
  /// Find all SimpleAudioDevices
  ///
  /// - Parameter direction:    Input / Output
  /// - Returns:                an array of SimpleAudioDevice
  ///
  private final class func getDeviceList(for direction: Direction) -> [AudioDevice] {
    
    var deviceArray = [AudioDevice]()
    var property = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                              mScope: kAudioObjectPropertyScopeGlobal,
                                              mElement: kAudioObjectPropertyElementMaster)
    var size: UInt32 = 0
    var numberOfDevices = 0
    
    // find the number of devices
    guard AudioObjectGetPropertyDataSize( AudioObjectID(kAudioObjectSystemObject), &property, 0, nil, &size ) == noErr else { fatalError() }
    numberOfDevices = Int(size) / MemoryLayout<AudioDeviceID>.size
    
    // get the device ids
    let deviceIDs = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfDevices)
    guard AudioObjectGetPropertyData( AudioObjectID(kAudioObjectSystemObject), &property, 0, nil, &size, deviceIDs ) == noErr else { fatalError() }
    numberOfDevices = Int(size) / MemoryLayout<AudioDeviceID>.size
    
    // iterate through the found devices
    for i in 0..<numberOfDevices {
      
      // is the device in the desired direction?
      if checkDirection(of: deviceIDs.advanced(by: i).pointee, for: direction) {
        
        // YES, initialize a SimpleAudioDevice
        if let device = AudioDevice( id: deviceIDs.advanced(by: i ).pointee, direction: direction ) {
          
          // add it to the array
          deviceArray.append( device )
        }
      }
    }
    return deviceArray
  }
  /// Find the direction (Input/Output) of a Device
  ///
  /// - Parameters:
  ///   - id:                 a Device ID
  ///   - direction:          the desired direction
  /// - Returns:              succecc / failure
  ///
  private class func checkDirection(of id: DeviceID, for direction: Direction) -> Bool {
    var size : UInt32 = 0
    
    // setup for the specified direction
    var propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreams,
                                                     mScope: direction == .input ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
                                                     mElement: 0)
    // get the number of devices with the specified id & direction
    guard AudioObjectGetPropertyDataSize(id, &propertyAddress, 0, nil, &size) == noErr else { fatalError() }
    
    // should be non-zero
    return (Int(size) / MemoryLayout<AudioStreamID>.size) != 0
  }
}

// ------------------------------------------------------------------------------
// MARK: - AudioDevice Struct implementation
// ------------------------------------------------------------------------------

public struct AudioDevice {
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kNoError                       = 0
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var id                             : AudioDeviceID
  public var direction                      : AudioHelper.Direction
  public var name                           : String? = nil
  public var uniqueID                       : String? = nil
  public var format                         : AudioStreamBasicDescription? = nil
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  init?(id: AudioDeviceID, direction: AudioHelper.Direction) {
    var string: CFString = "" as CFString
    var size = UInt32(MemoryLayout<CFString>.size)
    var nameProperty = AudioObjectPropertyAddress(mSelector: kAudioObjectPropertyName,
                                                  mScope: kAudioObjectPropertyScopeGlobal,
                                                  mElement: kAudioObjectPropertyElementMaster)
    var uniqueIDProperty = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceUID,
                                                      mScope: kAudioObjectPropertyScopeGlobal,
                                                      mElement: kAudioObjectPropertyElementMaster)
    self.id = id
    self.direction = direction
    
    // get the AudioStreamBasicDescription
    if let physicalFormat = getPhysicalFormat(for: id, for: direction ) {
      // save it
      format = physicalFormat
      
      // get the device name
      guard AudioObjectGetPropertyData( id, &nameProperty, 0, nil, &size, &string ) == AudioDevice.kNoError else { return nil }
      name = string as String
      
      // get the device uniqueID
      guard AudioObjectGetPropertyData( id, &uniqueIDProperty, 0, nil, &size, &string ) == AudioDevice.kNoError else { return nil }
      uniqueID = string as String
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Produce a description of this class
  ///
  /// - Returns:              a String representation of the class
  ///
  public func desc() -> String {
    return "name = \(name!)" + "\n" +
      "id = \(id)" + "\n" +
      "direction = \(direction.rawValue)" + "\n" +
      "uniqueID = \(uniqueID!)" + "\n" +
      "format = \(format!)" + "\n"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Get the AudioStreamBasicDescription
  ///
  /// - Parameters:
  ///   - deviceID:           a Device ID
  ///   - direction:          the specified direction
  /// - Returns:              an ASBD (if any)
  ///
  private func getPhysicalFormat(for deviceID: DeviceID, for direction: AudioHelper.Direction) -> AudioStreamBasicDescription? {
    var asbd = AudioStreamBasicDescription()
    var size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
    var formatProperty = AudioObjectPropertyAddress(mSelector: kAudioStreamPropertyPhysicalFormat,
                                                    mScope: kAudioDevicePropertyScopeOutput,
                                                    mElement: kAudioObjectPropertyElementMaster)
    // adjust the scope as needed
    if direction == .input { formatProperty.mScope = kAudioDevicePropertyScopeInput }
    
    // get the AudioStreamBasicDescription
    guard AudioObjectGetPropertyData( deviceID, &formatProperty, 0, nil, &size, &asbd ) == noErr else { fatalError() }
    
    return asbd
  }
}
