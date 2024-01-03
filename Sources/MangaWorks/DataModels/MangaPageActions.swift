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

/// Holds a collection of actions that the user can take on a given Manga Page.
@Observable open class MangaPageActions {
    
    // MARK: - Enumerations
    /// Defines which side of the `MangaActionsView` box the item appears.
    public enum ActionChoiceSide {
        /// The action will appear on the left side.
        case left
        
        /// The action will appear on the right side.
        case right
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
        
        let script:String = """
        main {
            call @playSoundEffect('\(soundEffect)', 3);
            call @adjustPoints(\(points));
            call @changePage('\(nextMangaPageID)');
        }
        """
        
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
