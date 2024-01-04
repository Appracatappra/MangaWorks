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

/// Holds information about a navigation point on a Manga Panorama Page.
open class MangaPageNavigationPoint: SimpleSerializeable {
    
    // MARK: - Properties
    /// A tag representing the action taken when this navigation point is triggered.
    public var tag:String = ""
    
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
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.navigationPoint)
            .append(tag)
            .append(layerVisibility)
            .append(soundEffect)
            .append(pitchLeading)
            .append(pitchTrailing)
            .append(yawLeading)
            .append(yawTrailing)
            .append(condition, isBase64Encoded: true)
        
        return serializer.value
    }
    
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
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.navigationPoint)
        
        self.tag = deserializer.string()
        self.layerVisibility.from(deserializer.int())
        self.soundEffect = deserializer.string()
        self.pitchLeading = deserializer.float()
        self.pitchTrailing = deserializer.float()
        self.yawLeading = deserializer.float()
        self.yawTrailing = deserializer.float()
        self.condition = deserializer.string(isBase64Encoded: true)
    }
}
