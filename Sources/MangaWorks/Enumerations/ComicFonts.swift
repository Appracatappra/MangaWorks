//
//  ComicFonts.swift
//  Escape from Mystic Manor
//
//  Created by Kevin Mullins on 2/4/22.
//

import Foundation
import SwiftUI

public enum ComicFonts:String {
    // MARK: - Cases and values
    case Komika = "KomikaText"
    case KomikaItalic = "KomikaText-Italic"
    case KomikaBold = "KomikaText-Bold"
    case KomikaBoldItalic = "KomikaText-BoldItalic"
    case KomikaKaps = "KomikaTextKaps"
    case KomikaKapsItalic = "KomikaTextKaps-Italic"
    case KomikaKapsBold = "KomikaTextKaps-Bold"
    case KomikaKapsBoldItalic = "KomikaTextKaps-BoldItalic"
    case KomikaTight = "KomikaTextTight"
    case KomikaTightItalic = "KomikaTextTight-Italic"
    
    case LuckiestGuy = "LuckiestGuy-Regular"
    
    case PlasmaDripFilled = "PlasmaDripBRK"
    case PlasmaDripEmpty = "PlasmaDripEmptyBRK"
    
    case Troika = "Troika"
    case TrueCrimes = "TrueCrimes"
    
    case bitwise = "bitwise"
    case endlessBummer = "ENDLESSBUMMER-Regular"
    case crackman = "CrackMan-Regular"
    case goodTimes = "GoodTimesRg-Regular"
    case johnnyFever = "JohnnyFever-Regular"
    case stillTime = "StillTime-Regular"
    case stormfaze = "Stormfaze-Regular"
    case strasua = "Strasua-Regular"
    
    // MARK: - Functions
    /// Gets the value from a string and defaults to `Komica` if the conversion is invalid.
    /// - Parameter value: The string to convert.
    public mutating func from(_ value:String) {
        if let enumeration = ComicFonts(rawValue: value) {
            self = enumeration
        } else {
            self = .Komika
        }
    }
    
    /// Returns a custom font of the requested size.
    /// - Parameter size: The size of the font to return.
    /// - Returns: The requested font in the requested size.
    public func ofSize(_ size:Float) -> Font {
        self.register()
        return Font.custom(self.rawValue, size: CGFloat(size))
    }
    
    /// Registers the given font with the Core Text Font Manager so that it can be used in a SwiftUI `View`.
    public func register() {
        var filename:String = ""
        
        // Get filename for given font
        switch self {
        case .Komika:
            filename = "KOMTXT__.ttf"
        case .KomikaItalic:
            filename = "KOMTXTI_.ttf"
        case .KomikaBold:
            filename = "KOMTXTB_.ttf"
        case .KomikaBoldItalic:
            filename = "KOMTXTBI.ttf"
        case .KomikaKaps:
            filename = "KOMTXTK_.ttf"
        case .KomikaKapsItalic:
            filename = "KOMTXTKI.ttf"
        case .KomikaKapsBold:
            filename = "KOMTXTKB.ttf"
        case .KomikaKapsBoldItalic:
            filename = "KOMTXKBI.ttf"
        case .KomikaTight:
            filename = "KOMTXTT_.ttf"
        case .KomikaTightItalic:
            filename = "KOMTXTTI.ttf"
        case .LuckiestGuy:
            filename = "luckiestguy.ttf"
        case .PlasmaDripFilled:
            filename = "plasdrip.ttf"
        case .PlasmaDripEmpty:
            filename = "plasdrpe.ttf"
        case .Troika:
            filename = "troika.otf"
        case .TrueCrimes:
            filename = "true-crimes.ttf"
        case .bitwise:
            filename = "bitwise.ttf"
        case .endlessBummer:
            filename = "ENDLESSBUMMER-Regular.otf"
        case .crackman:
            filename = "crackman.ttf"
        case .goodTimes:
            filename = "good times rg.otf"
        case .johnnyFever:
            filename = "johnny fever.otf"
        case .stillTime:
            filename = "still time.ttf"
        case .stormfaze:
            filename = "stormfaze.ttf"
        case .strasua:
            filename = "strasua.ttf"
        }
        
        guard filename != "" else {
            return
        }
        
        MangaWorks.registerFont(name: filename)
    }
}
