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

/// Holds a pin number that can be entered by the player to unlock a feature of a manga page.
@Observable open class MangaPagePin: SimpleSerializeable {
    
    // MARK: - Properties
    /// The title to display in the PIN editor.
    public var title:String = ""
    
    /// The PIN value that the user needs to enter.
    public var pinValue:String = ""
    
    /// The ID of the manga page to display in the user enters the PIN incorrectly.
    public var failMangaPageID:String = ""
    
    /// The ID of the manga page to display in the user enters the PIN correctly.
    public var succeedMangaPageID:String = ""
    
    /// The Grace Langauage script to run if the user enters the pin correctly.
    public var action:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.pagePin)
            .append(title)
            .append(pinValue)
            .append(failMangaPageID)
            .append(succeedMangaPageID)
            .append(action, isBase64Encoded: true)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new  instance.
    /// - Parameters:
    ///   - title: The title to display in the PIN editor.
    ///   - pinValue: The PIN value that the user needs to enter.
    ///   - failLocation: The ID of the manga page to display in the user enters the PIN incorrectly.
    ///   - succeedLocation: The ID of the manga page to display in the user enters the PIN correctly.
    ///   - action: The Grace Langauage script to run if the user enters the pin correctly.
    public init(title:String, pinValue:String = "", failLocation:String = "", succeedLocation:String = "", action:String = "") {
        // Initialize
        self.title = title
        self.pinValue = pinValue
        self.failMangaPageID = failLocation
        self.succeedMangaPageID = succeedLocation
        self.action = action
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized strin representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.pagePin)
        
        self.title = deserializer.string()
        self.pinValue = deserializer.string()
        self.failMangaPageID = deserializer.string()
        self.succeedMangaPageID = deserializer.string()
        self.action = deserializer.string(isBase64Encoded: true)
    }
}
