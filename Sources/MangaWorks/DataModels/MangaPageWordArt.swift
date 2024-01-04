//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SwiftUIPanoramaViewer
import SimpleSerializer

/// Hold information about a piece of word art that can be displayed on a manga page.
@Observable open class MangaPageWordArt: SimpleSerializeable {
    
    // MARK: - Properties
    /// The text of the word art to display.
    public var title:String = ""
    
    /// The font to display the word art in.
    public var font:ComicFonts = .TrueCrimes
    
    /// The font size to display the word art in.
    public var fontSize:Float = 128
    
    /// The gradient colors to display the word art in.
    public var gradientColors:[Color] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red]
    
    /// The rotational degreed for the word art gradient.
    public var rotationDegrees:Double = 0
    
    /// If `true`, add a shadow to the word art.
    public var shadowed:Bool = true
    
    /// The X offset for the word art.
    public var xOffset:Float = 0.0
    
    /// The Y offset for the word art.
    public var yOffset:Float = 0.0
    
    /// The layer visibility for the word art.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways
    
    /// A condition writen in Grace Langauge that must be met for the word art to display.
    public var condition:String = ""
    
    /// The leading pitch for displaying the word.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for displaying the word.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for displaying the word.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for displaying the word.
    public var yawTrailing:Float = 0.0
    
    /// The animation for the word art.
    public var animation:MangaAnimation = MangaAnimation()
    
    // MARK: - Computed Properties
    /// Returns a `MangaWordArtView` representing this word art object.
    public var view:some View {
        animation.reset()
        return MangaWordArtView(title: title, font: font, fontSize: fontSize * HardwareInformation.deviceRatioWidth, gradientColors: gradientColors, rotationDegrees: rotationDegrees, shadowed: shadowed, xOffset: xOffset * HardwareInformation.deviceRatioWidth, yOffset: yOffset * HardwareInformation.deviceRatioWidth).environmentObject(animation)
    }
    
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.wordArt)
            .append(title)
            .append(font)
            .append(fontSize)
            .append(array: gradientColors, divider: Divider.colors)
            .append(rotationDegrees)
            .append(shadowed)
            .append(xOffset)
            .append(yOffset)
            .append(layerVisibility)
            .append(condition, isBase64Encoded: true)
            .append(pitchLeading)
            .append(pitchTrailing)
            .append(yawLeading)
            .append(yawTrailing)
            .append(animation)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance
    /// - Parameters:
    ///   - title: The text of the word art to display.
    ///   - font: The font to display the word art in.
    ///   - fontSize: The font size to display the word art in.
    ///   - gradientColors: The gradient colors to display the word art in.
    ///   - rotationDegrees: The rotational degreed for the word art gradient.
    ///   - shadowed: If `true`, add a shadow to the word art.
    ///   - xOffset: The X offset for the word art.
    ///   - yOffset: The Y offset for the word art.
    ///   - layerVisibility: The layer visibility for the word art.
    ///   - pitch: The pitch to display the word art on.
    ///   - yaw: The yaw to display the word art on.
    ///   - animation: The animation for the word art.
    ///   - condition: A condition writen in Grace Langauge that must be met for the word art to display.
    public init(title:String, font:ComicFonts = .TrueCrimes, fontSize:Float = 128, gradientColors:[Color] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red], rotationDegrees:Double = 0, shadowed:Bool = true, xOffset:Float = 0.0, yOffset:Float = 0.0, layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = 0.0, yaw:Float = 0.0, animation:MangaAnimation = MangaAnimation(), condition:String = "") {
        // Initialize
        self.title = title
        self.font = font
        self.fontSize = fontSize
        self.gradientColors = gradientColors
        self.rotationDegrees = rotationDegrees
        self.shadowed = shadowed
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.layerVisibility = layerVisibility
        self.pitchLeading = PanoramaManager.leadingTarget(pitch)
        self.pitchTrailing = PanoramaManager.trailingTarget(pitch)
        self.yawLeading = PanoramaManager.leadingTarget(yaw)
        self.yawTrailing = PanoramaManager.trailingTarget(yaw)
        self.animation = animation
        self.condition = condition
    }
    
    /// Creates a new instance.
    /// - Parameter value: A string representing the serialized object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.wordArt)
        
        self.title = deserializer.string()
        self.font.from(deserializer.string())
        self.fontSize = deserializer.float()
        self.gradientColors = deserializer.array(divider: Divider.colors)
        self.rotationDegrees = deserializer.double()
        self.shadowed = deserializer.bool()
        self.xOffset = deserializer.float()
        self.yOffset = deserializer.float()
        self.layerVisibility.from(deserializer.int())
        self.condition = deserializer.string(isBase64Encoded: true)
        self.pitchLeading = deserializer.float()
        self.pitchTrailing = deserializer.float()
        self.yawLeading = deserializer.float()
        self.yawTrailing = deserializer.float()
        self.animation = deserializer.child()
    }
}
