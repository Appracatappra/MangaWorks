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

/// Holds a caption that can be displayed on a Manga Page.
@Observable open class MangaPageCaption {
    
    // MARK: - Properties
    /// The caption to display.
    public var caption:String = ""
    
    /// The font to display the caption in.
    public var font:ComicFonts = .KomikaTight
    
    /// The font size to display the caption in.
    public var fontSize:Float = 24
    
    /// The font color to display the caption in.
    public var fontColor:Color = Color.black
    
    /// The background color for the caption.
    public var backgroundColor:Color = Color.white
    
    /// The box width for the caption.
    public var boxWidth:Float = 200.0
    
    /// The X offset for the caption.
    public var xOffset:Float = 0.0
    
    /// The Y offset for the caption.
    public var yOffset:Float = 0.0
    
    /// The layer visibility for the caption.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways
    
    /// A condition written in the Grace Language that must be met before the caption is displayed.
    public var condition:String = ""
    
    /// The leading pitch for displaying the caption.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for displaying the caption.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for displaying the caption.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for displaying the caption.
    public var yawTrailing:Float = 0.0
    
    ///  The animation for the caption.
    public var animation:MangaAnimation = MangaAnimation()
    
    /// The voice to read the caption in.
    public var actor:MangaVoiceActors = .narrator
    
    // MARK: - Computed Properties
    /// Returns a `MangaCaptionView` representing the caption.
    public var view:some View {
        animation.reset()
        return MangaCaptionView(caption: caption, font:font, fontSize: fontSize * HardwareInformation.deviceRatioWidth, fontColor: fontColor, backgroundColor: backgroundColor, boxWidth: boxWidth * HardwareInformation.deviceRatioWidth, xOffset: xOffset * HardwareInformation.deviceRatioWidth, yOffset: yOffset * HardwareInformation.deviceRatioHeight).environmentObject(animation)
    }
    
    // MARK: - Initializers
    public init(actor:MangaVoiceActors = .narrator, caption:String, font:ComicFonts = .KomikaTight, fontSize:Float = 24, fontColor:Color = Color.black, backgroundColor:Color = Color.white, boxWidth:Float = 200.0, xOffset:Float = 0.0, yOffset:Float = 0.0, layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = 0.0, yaw:Float = 0.0, animation:MangaAnimation = MangaAnimation(), condition:String = "") {
        // Initialize
        self.actor = actor
        self.caption = caption
        self.font = font
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.boxWidth = boxWidth
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
    
}
