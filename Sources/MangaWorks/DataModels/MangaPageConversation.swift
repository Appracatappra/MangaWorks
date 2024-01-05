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

/// Holds a conversation that a player can have with a character at a given Manga Page with all of the possible actions the player can take.
@Observable open class MangaPageConversation: SimpleSerializeable {
    
    // MARK: - Enumerations
    /// Defines which side of the `MangaConversationView` box the item appears.
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
    /// The parent `MangaPage` that this conversation belongs to.
    public weak var parent:MangaPage? = nil
    
    /// The voice of the character being talked to.
    public var actor:MangaVoiceActors = .narrator
    
    /// The image of the character being talked to.
    public var portrait:String = ""
    
    /// The name of the character being talked to.
    public var name:String = ""
    
    /// The message that will be displayed in the `MangaConversationView`.
    public var message:String = ""
    
    /// The actions that will be displayed on the left side of the `MangaConversationView`.
    public var leftSide:[MangaPageAction] = []
    
    /// The actions that will be displayed on the right side of the `MangaConversationView`.
    public var rightSide:[MangaPageAction] = []
    
    /// The maximum number of action extries to display in the `MangaConversationView`.
    public var maxEntries:Int = 2
    
    /// The default layer element visibility for this conversation.
    public var visibility:MangaLayerManager.ElementVisibility = .displayNothing
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.conversation)
            .append(actor)
            .append(portrait)
            .append(name)
            .append(message)
            .append(children: leftSide, divider: Divider.actionDivider)
            .append(children: rightSide, divider: Divider.actionDivider)
            .append(maxEntries)
            .append(visibility)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - parent: The parent `MangaPage` that this conversation belongs to.
    ///   - actor: The voice of the character being talked to.
    ///   - portrait: The image of the character being talked to.
    ///   - name: The name of the character being talked to.
    ///   - message: The message that will be displayed in the `MangaConversationView`.
    ///   - visibility: The default layer element visibility for this conversation.
    ///   - maxEntries: The maximum number of action extries to display in the `MangaConversationView`.
    public init(parent:MangaPage, actor:MangaVoiceActors, portrait:String, name:String, message:String, visibility:MangaLayerManager.ElementVisibility, maxEntries:Int = 2) {
        // Initialize
        self.parent = parent
        self.actor = actor
        self.portrait = portrait
        self.name = name
        self.message = message
        self.maxEntries = maxEntries
        self.visibility = visibility
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.conversation)
        
        self.actor.from(deserializer.int())
        self.portrait = deserializer.string()
        self.name = deserializer.string()
        self.message = deserializer.string()
        self.leftSide = deserializer.children(divider: Divider.actionDivider)
        self.rightSide = deserializer.children(divider: Divider.actionDivider)
        self.maxEntries = deserializer.int()
        self.visibility.from(deserializer.int())
    }
    
    // MARK: - Functions
    /// Adds an action to this conversation.
    /// - Parameters:
    ///   - to: The side of the `MangaConversationView` to add the conversation to.
    ///   - text: The text of the conversation.
    ///   - condition: A condition written as a Grace Language macro that must be met for this action to be available.
    ///   - actionHandler: The Grace Language script to run if the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, condition:String = "", actionHandler:String = "") -> MangaPageConversation {
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
    
    /// Adds an action to the conversation.
    /// - Parameters:
    ///   - to: The side of the `MangaConversationView` to add the conversation to.
    ///   - text: The text of the conversation.
    ///   - soundEffect: An optional sound effect to play when the user takes this action.
    ///   - condition: A condition written as a Grace Language macro that must be met for this action to be available.
    ///   - points: Any optional adjustment to the user's points.
    ///   - nextMangaPageID: The next manga page to display if the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, soundEffect:String = "", condition:String = "", points:Int = 0, nextMangaPageID:String) -> MangaPageConversation {
        var id = 0
        
        switch to {
        case .left:
            id = leftSide.count
        case .right:
            id = rightSide.count + 10
        }
        
        let script:String = """
        import StandardLib;
        import StringLib;
        
        main {
            call @playSoundEffect('\(soundEffect)', 3);
            call @adjustIntState('points', \(points));
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
    
    /// Automatically appends a done action to the conversation before it is displayed if one doesn't already exist.
    /// - Returns: Returns self.
    public func appendDoneIfNeeded() -> MangaPageConversation {
        
        // Does the conversations already include done?
        for action in leftSide {
            if action.text == "Nothing, thanks." {
                return self
            }
        }
        for action in rightSide {
            if action.text == "Nothing, thanks." {
                return self
            }
        }
        
        let script:String = """
        main {
            call @changeLayerVisibility(0);
        }
        """
        
        // Build done and append to collection.
        let id = leftSide.count
        let action = MangaPageAction(id: id, text: "Nothing, thanks.", excute: script)
        leftSide.append(action)
        
        return self
    }
    
    /// Creates a anew conversation and adds it to the location.
    /// - Parameters:
    ///   - portrait: The character's portriat image.
    ///   - name: The characters name.
    ///   - message: The message to dispplay to the user.
    ///   - visibility: Which conversation slot ot add the conversation to.
    ///   - maxEntries: The maximum number of entries to display at one time.
    /// - Returns: The new conversation created.
    @discardableResult public func addConversation(actor:MangaVoiceActors, portrait:String, name:String, message:String, visibility:MangaLayerManager.ElementVisibility, maxEntries:Int = 2) -> MangaPageConversation {
        
        let parent = self.parent!
        let conversation = MangaPageConversation(parent: parent, actor: actor, portrait: portrait, name: name, message: message, visibility: visibility, maxEntries: maxEntries)
        
        switch visibility {
        case .displayConversationA:
            parent.conversationA = conversation
        case .displayConversationB:
            parent.conversationB = conversation
        default:
            break
        }
        
        return conversation
    }
}
