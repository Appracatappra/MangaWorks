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
    
    /// Defines the vertical placement of a cover item.
    public enum VerticalPlacement: Int {
        case top = 0
        case center
        case bottom
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `top` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = VerticalPlacement(rawValue: value) {
                self = enumeration
            } else {
                self = .top
            }
        }
    }
    
    /// Defines the fill mode of a cover item.
    public enum FillMode: Int {
        case stretch = 0
        case fit
        case fill
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `top` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = FillMode(rawValue: value) {
                self = enumeration
            } else {
                self = .stretch
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
    
    /// The cover background vertical placement.
    public var backgroundVerticalPlacement:VerticalPlacement = .top
    
    /// The cover background fill mode.
    public var backgroundFillMode:FillMode = .fit
    
    /// The cover's middle image.
    public var coverMiddleImage:String = ""
    
    /// The cover  middle vertical placement.
    public var middleVerticalPlacement:VerticalPlacement = .bottom
    
    /// The cover middle fill mode.
    public var middleFillMode:FillMode = .fit
    
    /// The cover's foreground image.
    public var coverForegroundImage:String = ""
    
    /// The cover foreground vertical palcement.
    public var foregroundVerticalPlacement:VerticalPlacement = .bottom
    
    /// The cover foreground fill mode.
    public var foregroundFillMode:FillMode = .fit
    
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
            .append(backgroundVerticalPlacement)
            .append(backgroundFillMode)
            .append(coverMiddleImage)
            .append(middleVerticalPlacement)
            .append(middleFillMode)
            .append(coverForegroundImage)
            .append(foregroundVerticalPlacement)
            .append(foregroundVerticalPlacement)
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
    ///   - backgroundVerticalPlacement: The cover background vertical placement.
    ///   - backgroundFillMode: The cover background fill mode.
    ///   - coverMiddleImage: The cover's middle image.
    ///   - middleVerticalPlacement: The cover  middle vertical placement.
    ///   - middleFillMode: The cover middle fill mode.
    ///   - coverForegroundImage: The cover's foreground image.
    ///   - foregroundVerticalPlacement: The cover foreground vertical palcement.
    ///   - foregroundFillMode: The cover foreground fill mode.
    ///   - coverBackgroundColor: The cover's background color.
    public init(imageSource: MangaWorks.Source = .appBundle, title: String = "", coverBackgroundImage: String = "", backgroundVerticalPlacement:VerticalPlacement = .top, backgroundFillMode:FillMode = .fit, coverMiddleImage: String = "", middleVerticalPlacement:VerticalPlacement = .bottom, middleFillMode:FillMode = .fit, coverForegroundImage: String = "", foregroundVerticalPlacement:VerticalPlacement = .bottom, foregroundFillMode:FillMode = .fit, coverBackgroundColor:Color = .white) {
        self.imageSource = imageSource
        self.title = title
        self.coverBackgroundImage = coverBackgroundImage
        self.backgroundVerticalPlacement = backgroundVerticalPlacement
        self.backgroundFillMode = backgroundFillMode
        self.coverMiddleImage = coverMiddleImage
        self.middleVerticalPlacement = middleVerticalPlacement
        self.middleFillMode = middleFillMode
        self.coverForegroundImage = coverForegroundImage
        self.foregroundVerticalPlacement = foregroundVerticalPlacement
        self.foregroundFillMode = foregroundFillMode
        self.coverBackgroundColor = coverBackgroundColor
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.mangaCover)
        
        self.imageSource.from(deserializer.int())
        self.title = deserializer.string()
        self.coverBackgroundImage = deserializer.string()
        self.backgroundVerticalPlacement.from(deserializer.int())
        self.backgroundFillMode.from(deserializer.int())
        self.coverMiddleImage = deserializer.string()
        self.middleVerticalPlacement.from(deserializer.int())
        self.middleFillMode.from(deserializer.int())
        self.coverForegroundImage = deserializer.string()
        self.foregroundVerticalPlacement.from(deserializer.int())
        self.foregroundFillMode.from(deserializer.int())
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
