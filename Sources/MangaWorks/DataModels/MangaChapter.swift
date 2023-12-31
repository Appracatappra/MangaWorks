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

/// Holds information about a Manga Chapter held in memory.
@Observable open class MangaChapter: SimpleSerializeable {
    
    // MARK: - Static Functions
    /// Registers `MangaChapter` functions with the Grace Language so they are available in MangaWorks Grace Scripts.
    public static func registerGraceFunctions() {
    }
    
    // MARK: - Properties
    /// The chapter's unique ID.
    public var id:String = ""
    
    /// If `true` this `MangaChapter` can be purged when not in use.
    public var isPurgable:Bool = true
    
    /// A collection of pages held in this chapter.
    public var pages:[MangaPage] = []
    
    // MARK: - Computed Properties
    /// Return the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.chapter)
            .append(id)
            .append(isPurgable)
            .append(children: pages, divider: Divider.pages)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The chapter's unique ID.
    ///   - isPurgable: If `true` this `MangaChapter` can be purged when not in use.
    public init(id: String, isPurgable:Bool = true) {
        self.id = id
        self.isPurgable = isPurgable
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.chapter)
        
        self.id = deserializer.string()
        self.isPurgable = deserializer.bool()
        self.pages = deserializer.children(divider: Divider.pages)
    }
    
    // MARK: - Functions
    /// Gets the requested page from the chapter.
    /// - Parameter id: The ID of the page to find.
    /// - Returns: Returns the page if found else returns `nil`.
    public func getPage(id:String) -> MangaPage? {
        
        // Scan all pages.
        for page in pages {
            if page.id == id {
                return page
            }
        }
        
        // Not Found
        return nil
    }
    
    /// Adds a page to this chapter.
    /// - Parameters:
    ///   - id: The unique ID of the page.
    ///   - pageType: The type of page to add.
    ///   - imageName: The full page or panorama image to add to the page.
    ///   - title: The title of the page.
    ///   - pageNumber: The page number. If zero the page number will be computed.
    ///   - previousPage: The ID of the previous page in the form `chapter|id`.
    ///   - nextPage: The ID of the next page in the form `chapter|id`.
    ///   - showStats: If `true` this page will show the player's stats.
    ///   - endGame: If `true` this page will end the game when displayed.
    ///   - suppressReadings: If `true`, this page will not automatically be read aloud.
    ///   - map: The image to display as a map of the location.
    ///   - blueprint: The image to display as a blueprint of the location.
    ///   - loadResourceTag: The tag of the ODR resource to load when this page loads.
    ///   - releaseResourceTag: The tag of the ODR resource to release when this page loads.
    ///   - prefetchResourceTag: The tag of the ODR resource to prefetch when this page loads.
    ///   - hintTag: The ID of any hints attached to this page.
    /// - Returns: Returns self.
    @discardableResult public func addPage(id:String, pageType:MangaPage.PageType, imageName:String = "", title:String = "", pageNumber:Int = 0, previousPage:String = "", nextPage:String = "", showStats:Bool = false, endGame:Bool = false, suppressReadings:Bool = false, map:String = "", blueprint:String = "", loadResourceTag:String = "", releaseResourceTag:String = "", prefetchResourceTag:String = "", hintTag:String = "") -> MangaChapter {
        
        // Get the page number.
        var num:Int = pageNumber
        if num == 0 {
            num = MangaBook.shared.totalPageCount
        }
        
        // Make a new page
        let page = MangaPage(id: id, pageType: pageType, imageName: imageName, chapter: self.id, title: title, pageNumber: num, previousPage: previousPage, nextPage: nextPage, showStats: showStats, endGame: endGame, suppressReadings: suppressReadings, map: map, blueprint: blueprint, loadResourceTag: loadResourceTag, releaseResourceTag: releaseResourceTag, prefetchResourceTag: prefetchResourceTag, hintTag: hintTag)
        
        // Add to collection.
        pages.append(page)
        
        return self
    }
}
