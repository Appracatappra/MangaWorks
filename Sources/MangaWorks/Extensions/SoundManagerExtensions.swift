//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/5/24.
//

import Foundation
import SwiftletUtilities
import SoundManager
import GraceLanguage
import SwiftUI
import LogManager

/// Extends `SoundManager` with `MangaWorks` specific features.
public extension SoundManager {
    
    // MARK: - Functions
    /// Gets the channel number from an int value.
    /// - Parameter value: The int value representing the channel.
    /// - Returns: Returns the channel or `channel01` if the channel is invalid.
    static func channel(from value:Int) -> SoundEffectChannel {
        if let enumeration = SoundEffectChannel(rawValue: value) {
            return enumeration
        } else {
            return .channel01
        }
    }
    
    /// Registers `SoundManager` functions with the Grace Language so they are available in MangaWorks Grace Scripts.
    static func registerGraceFunctions() {
        let compiler = GraceCompiler.shared
        
        // Add startBackgroundMusic
        compiler.register(name: "startBackgroundMusic", parameterNames: ["song"], parameterTypes: [.string]) { parameters in
            
            if let song = parameters["song"] {
                SoundManager.shared.startBackgroundMusic(song: song.string)
            }
            
            return nil
        }
        
        // Add playBackgroundSound
        compiler.register(name: "playBackgroundSound", parameterNames: ["sound"], parameterTypes: [.string]) { parameters in
            
            if let sound = parameters["sound"] {
                SoundManager.shared.playBackgroundSound(sound: sound.string)
            }
            
            return nil
        }
        
        // Add playBackgroundWeather
        compiler.register(name: "playBackgroundWeather", parameterNames: ["sound"], parameterTypes: [.string]) { parameters in
            
            if let sound = parameters["sound"] {
                SoundManager.shared.playBackgroundWeather(sound: sound.string)
            }
            
            return nil
        }
        
        // Add stopBackgroundMusic
        compiler.register(name: "stopBackgroundMusic", function: {parameters in
            SoundManager.shared.stopBackgroundMusic()
            
            return nil
        })
        
        // Add stopBackgroundSound
        compiler.register(name: "stopBackgroundSound", function: {parameters in
            SoundManager.shared.stopBackgroundSound()
            
            return nil
        })
        
        // Add stopBackgroundWeather
        compiler.register(name: "stopBackgroundWeather", function: {parameters in
            SoundManager.shared.stopBackgroundWeather()
            
            return nil
        })
        
        // Add stopSoundEffect
        compiler.register(name: "stopSoundEffect", parameterNames: ["channel"], parameterTypes: [.int]) { parameters in
            
            if let num = parameters["channel"] {
                let channel = SoundManager.channel(from: num.int)
                SoundManager.shared.stopSoundEffect(channel: channel)
            }
            
            return nil
        }
        
        // Add playSoundEffect
        compiler.register(name: "playSoundEffect", parameterNames: ["sound" ,"channel"], parameterTypes: [.string ,.int]) { parameters in
            
            if let sound = parameters["sound"] {
                if let num = parameters["channel"] {
                    let channel = SoundManager.channel(from: num.int)
                    SoundManager.shared.playSoundEffect(sound: sound.string, channel: channel)
                }
            }
            
            return nil
        }
    }
}
