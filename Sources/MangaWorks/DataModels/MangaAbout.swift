//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/11/24.
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

/// Holds information about the program's About Page.
@Observable open class MangaAbout {
    
    // MARK: - Properties
    /// Holds the name of the about page.
    public var aboutName:String = "About"
    
    /// The name of the program.
    public var programName:String = ""
    
    /// The copyright string.
    public var copyright:String = ""
    
    /// A collection of entries in the about page.
    public var entries:[MangaPageAction] = []
    
    /// An optional logo image.
    public var logoImage:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized:String {
        let serializer = Serializer(divider: ",")
            .append(aboutName)
            .append(programName)
            .append(copyright)
            .append(children: entries, divider: Divider.actionDivider)
            .append(logoImage)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - aboutName: Holds the name of the about page.
    ///   - programName: The name of the program.
    ///   - copyright: The copyright string.
    ///   - logoImage: A collection of entries in the about page.
    public init(aboutName:String = "About", programName: String = "", copyright:String = "", logoImage: String = "") {
        self.aboutName = aboutName
        self.programName = programName
        self.copyright = copyright
        self.logoImage = logoImage
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public init(from value:String) {
        let deserializer = Deserializer(text: value, divider: ",")
        
        self.aboutName = deserializer.string()
        self.programName = deserializer.string()
        self.copyright = deserializer.string()
        self.entries = deserializer.children(divider: Divider.actionDivider)
        self.logoImage = deserializer.string()
    }
    
    // MARK: - Functions
    /// Adds an entry to the about box.
    /// - Parameters:
    ///   - icon: An optional icon to display with the entry.
    ///   - text: The text of the entry to add.
    ///   - condition: A condition that must evaluate to `true` written as a Grace Language macro.
    ///   - excute: The Grace Language script to run when the user takes this action.
    /// - Returns: Returns Self.
    @discardableResult public func addEntry(icon:String = "", text:String, condition:String = "", excute:String = "") -> MangaAbout {
        let id = entries.count
        
        let entry = MangaPageAction(id: id, icon: icon, text: text, condition: condition, excute: excute)
        entries.append(entry)
        
        return self
    }
}
