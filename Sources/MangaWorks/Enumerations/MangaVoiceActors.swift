//
//  VoiceActors.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 11/18/22.
//

import Foundation

/// The voice to read any text in for a manga page.
public enum MangaVoiceActors: Int {
    /// In the narrator's voice.
    case narrator = 0
    
    /// In the electronic voice.
    case electronics
    
    /// In the male one voice.
    case maleOne
    
    /// In the male two voice.
    case maleTwo
    
    /// In the female one voice.
    case femaleOne
    
    /// In the female two voice.
    case femaleTwo
    
    // MARK: - Functions
    /// Gets the value from an `Int` and defaults to `narrator` if the conversion is invalid.
    /// - Parameter value: The value holding the Int to convert.
    public mutating func from(_ value:Int) {
        if let enumeration = MangaVoiceActors(rawValue: value) {
            self = enumeration
        } else {
            self = .narrator
        }
    }
}
