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

/// Defines a detailed image that can be displayed on a manga page.
@Observable open class MangaPageDetailImage {
    
    // MARK: - Properties
    /// The name of the image to display.
    public var imageName:String = ""
    
    /// The width of the image box.
    public var width:Float = 400.0
    
    /// The height of the image box.
    public var height:Float = 200.0
    
    /// The scale for the image.
    public var scale:Float = 0.20
    
    /// If `true`, display a background behind the image.
    public var hasBackground:Bool = true
    
    /// The background color for the image box.
    public var backgroundColor:Color = .black
    
    /// If `true`,  draw a shadow for the image.
    public var shadowed:Bool = true
    
    /// The X offset of the image.
    public var xOffset:Float = 0.0
    
    /// The Y offset of the image.
    public var yOffset:Float = 0.0
    
    /// The layer visibility for this image.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways
    
    /// The Grace Language condition that must be met before the image is displayed.
    public var condition:String = ""
    
    /// The leading pitch for displaying the image.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for displaying the image.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for displaying the image.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for displaying the image.
    public var yawTrailing:Float = 0.0
    
    /// The animation for the image.
    public var animation:MangaAnimation = MangaAnimation()
    
    // MARK: - Computed Properties
    /// Returns a `MangaImageView` representing the image.
    public var view:some View {
        animation.reset()
        return MangaImageView(imageName: imageName, width: width * HardwareInformation.deviceRatioWidth, height: height * HardwareInformation.deviceRatioHeight, scale: scale * HardwareInformation.deviceRatioWidth, hasBackground: hasBackground, background: backgroundColor, shadowed: shadowed, xOffset: xOffset * HardwareInformation.deviceRatioWidth, yOffset: yOffset * HardwareInformation.deviceRatioHeight).environmentObject(animation)
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageName: The name of the image to display.
    ///   - width: The width of the image box.
    ///   - height: The height of the image box.
    ///   - scale: The scale for the image.
    ///   - hasBackground: If `true`, display a background behind the image.
    ///   - backgroundColor: The background color for the image box.
    ///   - shadowed: If `true`,  draw a shadow for the image.
    ///   - xOffset: The X offset of the image.
    ///   - yOffset: The Y offset of the image.
    ///   - layerVisibility: The layer visibility for this image.
    ///   - pitch: The pitch to display the image at.
    ///   - yaw: The yaw to display the image at.
    ///   - animation: The animation for the image.
    ///   - condition: The Grace Language condition that must be met before the image is displayed.
    public init(imageName:String, width:Float = 400.0, height:Float = 200.0, scale:Float = 0.20, hasBackground:Bool = true, backgroundColor:Color = .black, shadowed:Bool = true, xOffset:Float = 0.0, yOffset:Float = 0.0, layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = 0.0, yaw:Float = 0.0, animation:MangaAnimation = MangaAnimation(), condition:String = "") {
        // Initialize
        self.imageName = imageName
        self.width = width
        self.height = height
        self.scale = scale
        self.hasBackground = hasBackground
        self.backgroundColor = backgroundColor
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
}
