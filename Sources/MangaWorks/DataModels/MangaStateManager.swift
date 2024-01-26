//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/11/24.
//

import Foundation
import SwiftUI
import SwiftletUtilities
import GraceLanguage
import SoundManager

/// Handles game specific states for Manga based games.
open class MangaStateManager {
    
    // MARK: - Static Functions
    /// Registers `MangaChapter` functions with the Grace Language so they are available in MangaWorks Grace Scripts.
    public static func registerGraceFunctions() {
        let compiler = GraceCompiler.shared
        
        // Add setPreference
        compiler.register(name: "setPreference", parameterNames: ["key", "value"], parameterTypes: [.string, .bool]) { parameters in
            
            if let key = parameters["key"] {
                if let value = parameters["value"] {
                    switch key.string {
                    case "playBackgroundMusic":
                        MangaStateManager.playBackgroundMusic = value.bool
                    case "playBackgroundSounds":
                        MangaStateManager.playBackgroundSounds = value.bool
                    case "playSoundEffects":
                        MangaStateManager.playSoundEffects = value.bool
                    case "speakText":
                        MangaStateManager.speakText = value.bool
                    case "autoReadPage":
                        MangaStateManager.autoReadPage = value.bool
                    case "readOnTap":
                        MangaStateManager.readOnTap = value.bool
                    case "expandOnTap":
                        MangaStateManager.expandOnTap = value.bool
                    default:
                        break
                    }
                }
            }
            
            return nil
        }
        
        // Add flipPreference
        compiler.register(name: "flipPreference", parameterNames: ["key"], parameterTypes: [.string]) { parameters in
            
            if let key = parameters["key"] {
                switch key.string {
                case "playBackgroundMusic":
                    MangaStateManager.playBackgroundMusic = !MangaStateManager.playBackgroundMusic
                    if !MangaStateManager.playBackgroundMusic {
                        SoundManager.shared.stopBackgroundMusic()
                    }
                case "playBackgroundSounds":
                    MangaStateManager.playBackgroundSounds = !MangaStateManager.playBackgroundSounds
                    if !MangaStateManager.playBackgroundSounds {
                        SoundManager.shared.stopBackgroundSound()
                        SoundManager.shared.stopBackgroundWeather()
                    }
                case "playSoundEffects":
                    MangaStateManager.playSoundEffects = !MangaStateManager.playSoundEffects
                case "speakText":
                    MangaStateManager.speakText = !MangaStateManager.speakText
                case "autoReadPage":
                    MangaStateManager.autoReadPage = !MangaStateManager.autoReadPage
                case "readOnTap":
                    MangaStateManager.readOnTap = !MangaStateManager.readOnTap
                case "expandOnTap":
                    MangaStateManager.expandOnTap = !MangaStateManager.expandOnTap
                default:
                    break
                }
            }
            
            return nil
        }
        
        // Add getPreference
        compiler.register(name: "getPreference", parameterNames: ["key"], parameterTypes: [.string], returnType: .bool) { parameters in
            var value:Bool = false
            
            if let key = parameters["key"] {
                switch key.string {
                case "playBackgroundMusic":
                    value = MangaStateManager.playBackgroundMusic
                case "playBackgroundSounds":
                    value = MangaStateManager.playBackgroundSounds
                case "playSoundEffects":
                    value = MangaStateManager.playSoundEffects
                case "speakText":
                    value = MangaStateManager.speakText
                case "autoReadPage":
                    value = MangaStateManager.autoReadPage
                case "readOnTap":
                    value = MangaStateManager.readOnTap
                case "expandOnTap":
                    value = MangaStateManager.expandOnTap
                default:
                    break
                }
            }
            
            return GraceVariable(name: "result", value: "\(value)", type: .bool)
        }
        
        // Add getPreference
        compiler.register(name: "getPreferenceState", parameterNames: ["key"], parameterTypes: [.string], returnType: .bool) { parameters in
            var value:Bool = false
            
            if let key = parameters["key"] {
                switch key.string {
                case "playBackgroundMusic":
                    value = MangaStateManager.playBackgroundMusic
                case "playBackgroundSounds":
                    value = MangaStateManager.playBackgroundSounds
                case "playSoundEffects":
                    value = MangaStateManager.playSoundEffects
                case "speakText":
                    value = MangaStateManager.speakText
                case "autoReadPage":
                    value = MangaStateManager.autoReadPage
                case "readOnTap":
                    value = MangaStateManager.readOnTap
                case "expandOnTap":
                    value = MangaStateManager.expandOnTap
                default:
                    break
                }
            }
            
            var state:String = ""
            if value {
                state = "ON"
            } else {
                state = "OFF"
            }
            
            return GraceVariable(name: "result", value: state, type: .bool)
        }
    }
    
    /// If `true`, play the background music in the game.
    @AppStorage("playBackgroundMusic") public static var playBackgroundMusic: Bool = true
    
    /// If `true`, play background sound effects in the game.
    @AppStorage("playBackgroundSounds") public static var playBackgroundSounds: Bool = true
    
    /// If `true` play sound effects in the game.
    @AppStorage("playSoundEffects") public static var playSoundEffects: Bool = true
    
    /// If `true`, allow the device to read text.
    @AppStorage("speakText") public static var speakText: Bool = true
    
    /// If `true`, automatically read all of the text on a page when it loads.
    @AppStorage("autoReadPage") public static var autoReadPage: Bool = false
    
    /// If `true`, read the text when it is tapped on.
    @AppStorage("readOnTap") public static var readOnTap: Bool = false
    
    /// If `true`, expand the text when it is tapped on.
    @AppStorage("expandOnTap") public static var expandOnTap: Bool = true
}
