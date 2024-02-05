//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation
import SimpleSerializer

/// Class to hold an action that a user can take on a Manga Page.
@Observable open class MangaPageAction: Identifiable, SimpleSerializeable {
    
    // MARK: - Properties
    /// The unique ID of the action.
    public var id:Int = 0
    
    /// An optional icon to display with the entry.
    public var icon:String = ""
    
    /// The text description of the action.
    public var text:String = ""
    
    /// A condition that must evaluate to `true` written as a Grace Language macro.
    public var condition:String = ""
    
    /// The Grace Language script to run when the user takes this action.
    public var excute:String = ""
    
    // MARK: - Computed Properties
    /// Returns a `MangaActionView` for this action.
    public var view:MangaActionView {
        return MangaActionView(text: text, action: excute)
    }
    
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.action)
            .append(id)
            .append(icon)
            .append(text)
            .append(condition, isBase64Encoded: true)
            .append(excute, isBase64Encoded: true)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The unique ID of the action.
    ///   - icon: An optional icon to display with the entry.
    ///   - text: The text description of the action.
    ///   - condition: A condition that must evaluate to `true` written as a Grace Language macro.
    ///   - excute: The Grace Language script to run when the user takes this action.
    public init(id:Int, icon:String = "", text:String, condition:String = "", excute:String = "") {
        // Initialize
        self.id = id
        self.icon = icon
        self.text = text
        self.excute = excute
        self.condition = condition
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.action)
        
        self.id = deserializer.int()
        self.icon = deserializer.string()
        self.text = deserializer.string()
        self.condition = deserializer.string(isBase64Encoded: true)
        self.excute = deserializer.string(isBase64Encoded: true)
    }
}
