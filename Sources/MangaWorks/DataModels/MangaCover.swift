//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/5/24.
//

import Foundation
import SwiftletUtilities
import LogManager
import SpeechManager
import GraceLanguage
import SwiftUIPanoramaViewer
import SwiftUI
import SoundManager
import SimpleSerializer
import Observation

@Observable open class MangaCover: SimpleSerializeable {
    
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
    /// The source for the cover's images.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The manga's title.
    public var title:String = ""
    
    /// The cover background image.
    public var coverBackgroundImage:String = ""
    
    /// The cover's middle image.
    public var coverMiddleImage:String = ""
    
    /// The cover's foreground image.
    public var coverForegroundImage:String = ""
    
    /// The cover's background color.
    public var coverBackgroundColor:Color = .white
    
    /// The actions that will be displayed on the left side of the cover.
    public var leftSide:[MangaPageAction] = []
    
    /// The actions that will be displayed on the right side of the cover.
    public var rightSide:[MangaPageAction] = []
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.mangaCover)
            .append(imageSource)
            .append(title)
            .append(coverBackgroundImage)
            .append(coverMiddleImage)
            .append(coverForegroundImage)
            .append(coverBackgroundColor)
            .append(children: leftSide, divider: Divider.actionDivider)
            .append(children: rightSide, divider: Divider.actionDivider)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: The source for the cover's images.
    ///   - title: The manga's title.
    ///   - coverBackgroundImage: The cover background image.
    ///   - coverMiddleImage: The cover's middle image.
    ///   - coverForegroundImage: The cover's foreground image.
    public init(imageSource: MangaWorks.Source = .appBundle, title: String = "", coverBackgroundImage: String = "", coverMiddleImage: String = "", coverForegroundImage: String = "") {
        self.imageSource = imageSource
        self.title = title
        self.coverBackgroundImage = coverBackgroundImage
        self.coverMiddleImage = coverMiddleImage
        self.coverForegroundImage = coverForegroundImage
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.mangaCover)
        
        self.imageSource.from(deserializer.int())
        self.title = deserializer.string()
        self.coverBackgroundImage = deserializer.string()
        self.coverMiddleImage = deserializer.string()
        self.coverForegroundImage = deserializer.string()
        self.coverBackgroundColor = deserializer.color()
        self.leftSide = deserializer.children(divider: Divider.actionDivider)
        self.rightSide = deserializer.children(divider: Divider.actionDivider)
    }
    
    // MARK: - Functions
    /// Adds an action to this conversation.
    /// - Parameters:
    ///   - to: The side of the `MangaConversationView` to add the conversation to.
    ///   - text: The text of the conversation.
    ///   - condition: A condition written as a Grace Language macro that must be met for this action to be available.
    ///   - actionHandler: The Grace Language script to run if the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, condition:String = "", actionHandler:String = "") -> MangaCover {
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
    @discardableResult public func addAction(to:ActionChoiceSide, text:String, soundEffect:String = "", condition:String = "", points:Int = 0, nextMangaPageID:String) -> MangaCover {
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
}
