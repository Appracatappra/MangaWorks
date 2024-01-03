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

/// Holds a user interaction that can be attached to a Manga Panorama Page.
open class MapInteraction {
    
    // MARK: - Enumerations
    /// The type of action that the user can take at a given pitch and yaw in a manga panorama page.
    public enum ActionType {
        /// Search the given position.
        case search
        
        /// Use an item at the given position.
        case use
        
        /// Talk to a character at the given position.
        case talk
        
        /// Examine an item at the given position.
        case examine
        
        /// Navigate to a new Manga Page from the given position.
        case navigation
        
        /// Attack a character at the given position.
        case attack
        
        /// Hack an electronic device at the given position.
        case hack
        
        /// Place a call from the given position.
        case call
        
        /// Returns the icon to display for the given interaction.
        public var icon:String {
            switch self {
            case .search:
                return  "eye.trianglebadge.exclamationmark"
            case .use:
                return "dot.circle.and.hand.point.up.left.fill"
            case .talk:
                return "person.crop.circle.badge.questionmark.fill"
            case .examine:
                return "questionmark.square.dashed"
            case .navigation:
                return "arrow.up.circle.fill"
            case .attack:
                return "person.crop.circle.badge.exclamationmark.fill"
            case .hack:
                return "desktopcomputer.trianglebadge.exclamationmark"
            case .call:
                return "iphone.homebutton.radiowaves.left.and.right"
            }
        }
    }
    
    // MARK: - Properties
    /// The type of action to take.
    public var action:ActionType = .examine
    
    /// The title of the interaction.
    public var title:String = ""
    
    /// The Layer Manager element to display when the user takes this action.
    public var displayElement:MangaLayerManager.ElementVisibility = .displayNothing
    
    /// A notebook to record a message in for the player when this interaction is triggered.
    public var notebook:String = ""
    
    /// A notebook title to record a message in for the player when this interaction is triggered.
    public var notebookTitle:String = ""
    
    /// A notebook entry to record a message in for the player when this interaction is triggered.
    public var notebookEntry:String = ""
    
    /// A Grace Language Script that must evaluate to `true` before this instraction is available.
    public var condition:String = ""
    
    /// A Grace Language Script to run when the user triggeres this interaction.
    public var handler:String = ""
    
    /// The leading pitch for the interaction target.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for the interaction target.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for the interaction target.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for the interaction target.
    public var yawTrailing:Float = 0.0
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - action: The type of action to take.
    ///   - title: The title of the interaction.
    ///   - displayElement: The Layer Manager element to display when the user takes this action.
    ///   - pitch: The picth to show the interaction at.
    ///   - yaw: The yaw to show the interaction at.
    ///   - notebook: A notebook to record a message in for the player when this interaction is triggered.
    ///   - notebookTitle:  A notebook title to record a message in for the player when this interaction is triggered.
    ///   - notebookEntry: A notebook entry to record a message in for the player when this interaction is triggered.
    ///   - condition: A Grace Language Script that must evaluate to `true` before this instraction is available.
    ///   - handler: A Grace Language Script to run when the user triggeres this interaction.
    init(action:ActionType, title:String, displayElement:MangaLayerManager.ElementVisibility, pitch:Float = 0.0, yaw:Float = 0.0, notebook:String = "", notebookTitle:String = "", notebookEntry:String = "", condition:String = "", handler:String = "") {
        // Initialize
        self.action = action
        self.title = title
        self.displayElement = displayElement
        self.pitchLeading = PanoramaManager.leadingTarget(pitch, targetType: .interaction)
        self.pitchTrailing = PanoramaManager.trailingTarget(pitch, targetType: .interaction)
        self.yawLeading = PanoramaManager.leadingTarget(yaw, targetType: .interaction)
        self.yawTrailing = PanoramaManager.trailingTarget(yaw, targetType: .interaction)
        self.notebook = notebook
        self.notebookTitle = notebookTitle
        self.notebookEntry = notebookEntry
        self.handler = handler
        self.condition = condition
    }
}
