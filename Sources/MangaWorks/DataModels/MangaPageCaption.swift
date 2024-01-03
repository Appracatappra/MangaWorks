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

@Observable open class MangaPageCaption {
    
    // MARK: - Properties
    var caption:String = ""
    
    var font:ComicFonts = .KomikaTight
    
    var fontSize:Float = 24
    
    var fontColor:Color = Color.black
    
    var backgroundColor:Color = Color.white
    
    var boxWidth:Float = 200.0
    
    var xOffset:Float = 0.0
    
    var yOffset:Float = 0.0
    
    var layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways
    
    var condition:String = ""
    
    var pitchLeading:Float = 0.0
    
    var pitchTrailing:Float = 0.0
    
    var yawLeading:Float = 0.0
    
    var yawTrailing:Float = 0.0
    
    var animation:MangaAnimation = MangaAnimation()
    
    var actor:MangaVoiceActors = .narrator
    
    // MARK: - Computed Properties
    var view:some View {
        animation.reset()
        return MangaCaptionView(caption: caption, font:font, fontSize: fontSize * HardwareInformation.deviceRatioWidth, fontColor: fontColor, backgroundColor: backgroundColor, boxWidth: boxWidth * HardwareInformation.deviceRatioWidth, xOffset: xOffset * HardwareInformation.deviceRatioWidth, yOffset: yOffset * HardwareInformation.deviceRatioHeight).environmentObject(animation)
    }
    
    // MARK: - Initializers
    init(actor:MangaVoiceActors = .narrator, caption:String, font:ComicFonts = .KomikaTight, fontSize:Float = 24, fontColor:Color = Color.black, backgroundColor:Color = Color.white, boxWidth:Float = 200.0, xOffset:Float = 0.0, yOffset:Float = 0.0, layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = 0.0, yaw:Float = 0.0, animation:MangaAnimation = MangaAnimation(), condition:String = "") {
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
