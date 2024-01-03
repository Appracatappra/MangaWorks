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

/// Holds information about a navigation point on a Manga Panorama Page.
open class MangaPageNavigationPoint {
    
    // MARK: - Properties
    /// A tag representing the action taken when this navigation point is triggered.
    public var tag:String
    
    /// The layer visibility for this navigation point.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .displayNothing
    
    /// The sound effect to play when this navigation point is triggered.
    public var soundEffect:String = ""
    
    /// The leading pitch for displaying the navigation point.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for displaying the navigation point.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for displaying the navigation point.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for displaying the navigation point.
    public var yawTrailing:Float = 0.0
    
    /// A condition written in the Grace Language that must be met before the navigation is active.
    public var condition:String = ""
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - tag: A tag representing the action taken when this navigation point is triggered.
    ///   - layerVisibility: The layer visibility for this navigation point.
    ///   - soundEffect: The sound effect to play when this navigation point is triggered.
    ///   - pitch: The pitch to display the navigation point at.
    ///   - yaw: The yaw to display the navigation point at.
    ///   - condition: A condition written in the Grace Language that must be met before the navigation is active.
    public init(tag:String, layerVisibility:MangaLayerManager.ElementVisibility = .displayNothing, soundEffect:String = "", pitch:Float = 0.0, yaw:Float = 0.0, condition:String = "") {
        // Initialize
        self.tag = tag
        self.layerVisibility = layerVisibility
        self.soundEffect = soundEffect
        self.pitchLeading = PanoramaManager.leadingTarget(pitch)
        self.pitchTrailing = PanoramaManager.trailingTarget(pitch)
        self.yawLeading = PanoramaManager.leadingTarget(yaw)
        self.yawTrailing = PanoramaManager.trailingTarget(yaw)
        self.condition = condition
    }
}
