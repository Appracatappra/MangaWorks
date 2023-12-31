//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation

/// Defines the placement of an element on a manga page.
public enum MangaPageElementPlacement: Int {
    /// Top leading placement.
    case topLeading = 0
    
    /// Top center placement.
    case topCenter
    
    /// Top trailing placement.
    case topTrailing
    
    /// Upper Middle leading placement.
    case upperMiddleLeading
    
    /// Upper Middle center placement.
    case upperMiddleCenter
    
    /// Upper Middle trailing placement.
    case upperMiddleTrailing
    
    /// Lower Middle leading placement.
    case lowerMiddleLeading
    
    /// Lower Middle center placement.
    case lowerMiddleCenter
    
    /// Lower Middle trailing placement.
    case lowerMiddleTrailing
    
    /// Bottom leading placement.
    case bottomLeading
    
    /// Bottom center placement.
    case bottomCenter
    
    /// Bottom trailing placement.
    case bottomTrailing
    
    // MARK: - Functions
    /// Gets the value from an `Int` and defaults to `topLeading` if the conversion is invalid.
    /// - Parameter value: The value holding the Int to convert.
    public mutating func from(_ value:Int) {
        if let enumeration = MangaPageElementPlacement(rawValue: value) {
            self = enumeration
        } else {
            self = .topLeading
        }
    }
}
