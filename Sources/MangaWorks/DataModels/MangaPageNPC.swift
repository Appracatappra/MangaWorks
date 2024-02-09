//
//  File.swift
//  
//
//  Created by Kevin Mullins on 2/9/24.
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SimpleSerializer

/// Holds an instance of a NPC at a give page location.
open class MangaPageNPC: SimpleSerializeable {
    
    // MARK: - Properties
    /// The theme that the NPC should be triggered for. Zero will match any theme.
    public var theme:Int = 0
    
    /// The unique ID of the NPC.
    public var id:String = ""
    
    /// The address of the page that holds the conversation.
    public var conversationPage:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.conversation)
            .append(theme)
            .append(id)
            .append(conversationPage)
     
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - theme: The theme that the NPC should be triggered for. Zero will match any theme.
    ///   - id: The unique ID of the NPC.
    ///   - conversationPage: The address of the page that holds the conversation.
    public init(theme: Int, id: String, conversationPage: String) {
        self.theme = theme
        self.id = id
        self.conversationPage = conversationPage
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.conversation)
        
        self.theme = deserializer.int()
        self.id = deserializer.string()
        self.conversationPage = deserializer.string()
    }
}
