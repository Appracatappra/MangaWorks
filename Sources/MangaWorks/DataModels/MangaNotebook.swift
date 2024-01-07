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

/// Holds any notes that the user has discovered in the MangaPages.
@Observable open class MangaNotebook: SimpleSerializeable {
    
    // MARK: - Properties
    /// The title of the main notebook.
    public var title:String = ""
    
    /// A collection of notebook entries.
    public var entries:[MangaNotebookEntry] = []
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.notebook)
            .append(title)
            .append(children: entries, divider: Divider.notebookEntries)
        
        return serializer.value
    }
 
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameter title: The title of the main notebook.
    public init(title: String = "") {
        self.title = title
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.notebookEntry)
        
        self.title = deserializer.string()
        self.entries = deserializer.children(divider: Divider.notebookEntries)
    }
    
    // MARK: - Functions
    /// Gets the notebooks entry with the given ID.
    /// - Parameter notebookID: The ID of the entry to get.
    /// - Returns: Returns the entry or `nil` if not found.
    public func getEntry(notebookID:String) -> MangaNotebookEntry? {
        
        // Scan all entries
        for entry in entries {
            if entry.notebookID == notebookID {
                return entry
            }
        }
        
        // Not found
        return nil
    }
    
    /// Gets an existing entry or creates a new one.
    /// - Parameter notebookID: The ID of the entry to get.
    /// - Returns: Returns a new or existing entry.
    public func getEntryOrReturnNew(notebookID:String) -> MangaNotebookEntry {
        if let entry = getEntry(notebookID: notebookID) {
            return entry
        } else {
            let entry = MangaNotebookEntry(notebookID: notebookID)
            entries.append(entry)
            return entry
        }
    }
    
    /// Saves an entry to the notebook.
    /// - Parameters:
    ///   - notebookID: The ID of the entry to save.
    ///   - image: An image for the entry.
    ///   - title: The title of the entry.
    ///   - entry: The body of the entry.
    public func saveEntry(notebookID: String = "", image: String = "", title: String = "", entry: String = "") {
        let note = getEntryOrReturnNew(notebookID: notebookID)
        
        note.image = image
        note.title = title
        note.entry = entry
    }
}
