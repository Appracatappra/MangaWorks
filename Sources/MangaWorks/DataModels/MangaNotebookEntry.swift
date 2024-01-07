//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/7/24.
//

import Foundation
import SwiftUI
import Observation
import SimpleSerializer

/// Holds an entry in a Manga notebook.
@Observable open class MangaNotebookEntry: SimpleSerializeable {
    
    // MARK: - Properties
    /// The unique ID of the notebook entry.
    public var notebookID:String = ""
    
    /// An optional image for the entry.
    public var image:String = ""
    
    /// The title of the entry.
    public var title:String = ""
    
    /// The body of the entry.
    public var entry:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.notebookEntry)
            .append(notebookID)
            .append(image)
            .append(title)
            .append(entry, isBase64Encoded: true)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - notebookID: The unique ID of the notebook entry.
    ///   - image: An optional image for the entry.
    ///   - title: The title of the entry.
    ///   - entry: The body of the entry.
    public init(notebookID: String = "", image: String = "", title: String = "", entry: String = "") {
        self.notebookID = notebookID
        self.image = image
        self.title = title
        self.entry = entry
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.notebookEntry)
        
        self.notebookID = deserializer.string()
        self.image = deserializer.string()
        self.title = deserializer.string()
        self.entry = deserializer.string(isBase64Encoded: true)
    }
}
