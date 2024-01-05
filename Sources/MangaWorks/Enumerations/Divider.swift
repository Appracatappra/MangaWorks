//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/4/24.
//

import Foundation

/// Holds all of the divider characters used in Serializing/Deserializing Maga Page data using the `SimpleSerializer`.
public enum Divider:String, Codable {
    case animation = "Ω"
    case wordArt = "≈"
    case colors = "ç"
    case pageSymbol = "√"
    case speechBalloon = "∫"
    case pagePin = "˜"
    case pagePanel = "µ"
    case navigationPoint = "≤"
    case interaction = "≥"
    case hint = "÷"
    case detailImage = "æ"
    case action = "¬"
    case actionDivider = "∆"
    case conversation = "˚"
    case pageCaption = "˙"
    case pageActions = "ƒ"
    case page = "∂"
    case pageElements = "«"
    case pages = "≠"
    case touchZone = "ß"
    case chapter = "å"
    case chapters = "ø"
    case mangaBook = "¥"
}
