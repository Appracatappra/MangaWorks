//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation
import GraceLanguage
import SimpleSerializer

/// Holds a symbol that can be entered by the play to gain access to a feature of a given manga page.
/// The symbol can be represented by a series of 1's and 0's in the form: "1111|0110|0110|1111".
@Observable open class MangaPageSymbol:SimpleSerializeable {
   
    // MARK: - Properties
    /// The title to display in the symbol entry editor.
    public var title:String = ""
    
    /// The symbol pattern as a series of 1's and 0's in the form: "1111|0110|0110|1111".
    public var symbolValue:String = ""
    
    /// The ID of the manga page to jump to if the user enters the pattern incorrectly.
    public var failMangaPageID:String = ""
    
    /// The ID of the manga page to display if the user enters the pattern correctly.
    public var succeedMangaPageID:String = ""
    
    /// The Grace Langruage script to execute if the user enters the symbol correctly.
    public var action:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.pageSymbol)
            .append(title)
            .append(symbolValue)
            .append(failMangaPageID)
            .append(succeedMangaPageID)
            .append(action, isBase64Encoded: true)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - title: The title to display in the symbol entry editor.
    ///   - symbolValue: The symbol pattern as a series of 1's and 0's in the form: "1111|0110|0110|1111".
    ///   - failLocation: The ID of the manga page to jump to if the user enters the pattern incorrectly.
    ///   - succeedLocation: The ID of the manga page to jump to if the user enters the pattern correctly.
    ///   - action: The Grace Langruage script to execute if the user enters the symbol correctly.
    public init(title:String, symbolValue:String = "", failLocation:String = "", succeedLocation:String = "", action:String = "") {
        // Initialize
        self.title = title
        self.symbolValue = symbolValue
        self.failMangaPageID = failLocation
        self.succeedMangaPageID = succeedLocation
        self.action = action
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.pageSymbol)
        
        self.title = deserializer.string()
        self.symbolValue = deserializer.string()
        self.failMangaPageID = deserializer.string()
        self.succeedMangaPageID = deserializer.string()
        self.action = deserializer.string(isBase64Encoded: true)
    }
}
