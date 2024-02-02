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
import SimpleSerializer

/// Holds a collection of actions that the user can take on a given Manga Page.
@Observable open class MangaPageActions: SimpleSerializeable {
    
    // MARK: - Enumerations
    /// Defines which side of the `MangaActionsView` box the item appears.
    public enum ActionChoiceSide: Int {
        /// The action will appear on the left side.
        case left = 0
        
        /// The action will appear on the right side.
        case right
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `left` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = ActionChoiceSide(rawValue: value) {
                self = enumeration
            } else {
                self = .left
            }
        }
    }
    
    // MARK: - Properties
    /// The title to display in the `MangaActionsView`.
    public var title:String = ""
    
    /// The actions that will be displayed in the left side of the `MangaActionsView`.
    public var leftSide:[MangaPageAction] = []
    
    /// The actions that will be displayed on the right side of the `MangaActionsView`.
    public var rightSide:[MangaPageAction] = []
    
    /// The maximum number of actions to display in the `MangaActionsView`.
    public var maxEntries:Int = 2
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.pageActions)
            .append(title)
            .append(children: leftSide, divider: Divider.actionDivider)
            .append(children: rightSide, divider: Divider.actionDivider)
            .append(maxEntries)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - title: The title to display in the `MangaActionsView`.
    ///   - maxEntries: The maximum number of actions to display in the `MangaActionsView`.
    public init(title:String = "", maxEntries:Int = 2) {
        // Initialize
        self.title = title
        self.maxEntries = maxEntries
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.pageActions)
        
        self.title = deserializer.string()
        self.leftSide = deserializer.children(divider: Divider.actionDivider)
        self.rightSide = deserializer.children(divider: Divider.actionDivider)
        self.maxEntries = deserializer.int()
    }
    
    // MARK: - Functions
    /// Adds an action that the user can take.
    /// - Parameters:
    ///   - to: The side of the `MangaActionsView` to display the action in.
    ///   - text: The text of the action.
    ///   - condition: A condition written as a Grace Langauage macro that must be met before this action can be taken.
    ///   - actionHandler: The Grace Language script to execute when the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, condition:String = "", actionHandler:String = "") -> MangaPageActions {
        var id = 0
        
        switch to {
        case .left:
            id = leftSide.count
        case .right:
            id = rightSide.count + 10
        }
        
        let action = MangaPageAction(id: id, text: text, condition: condition, excute: actionHandler)
        
        switch to {
        case .left:
            leftSide.append(action)
        case .right:
            rightSide.append(action)
        }
        
        return self
    }
    
    /// Adds an action that the user can take.
    /// - Parameters:
    ///   - to: The side of the `MangaActionsView` to display the action in.
    ///   - text: The text of the action.
    ///   - soundEffect: An optional sound effect to play when the user takes the action.
    ///   - condition: A condition written as a Grace Langauage macro that must be met before this action can be taken.
    ///   - points: Optionally adjust the points if the user takes this action.
    ///   - nextMangaPageID: The next manga page to display if the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, soundEffect:String = "", condition:String = "", points:Int = 0, nextMangaPageID:String) -> MangaPageActions {
        var id = 0
        
        switch to {
        case .left:
            id = leftSide.count
        case .right:
            id = rightSide.count + 10
        }
        
        let script = MangaPage.composeGraceScript(soundEffect: soundEffect, points: points, pageID: nextMangaPageID)
        
        let action = MangaPageAction(id: id, text: text, condition: condition, excute: script)
        
        switch to {
        case .left:
            leftSide.append(action)
        case .right:
            rightSide.append(action)
        }
        
        return self
    }
}
