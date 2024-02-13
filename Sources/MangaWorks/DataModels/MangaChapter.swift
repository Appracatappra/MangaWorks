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
        let compiler = GraceCompiler.shared
        
        // Add pageHasMap
        compiler.register(name: "pageHasMap", parameterNames: [], parameterTypes: [], returnType: .bool) { parameters in
            var value = ""
            
            let has = (MangaBook.shared.currentPage.map != "")
            value = "\(has)"
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add pageHasBlueprints
        compiler.register(name: "pageHasBlueprints", parameterNames: [], parameterTypes: [], returnType: .bool) { parameters in
            var value = ""
            
            let has = (MangaBook.shared.currentPage.blueprints != "")
            value = "\(has)"
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add handleLayerChange
        compiler.register(name: "handleLayerChange", parameterNames: [], parameterTypes: []) { parameters in
            
            MangaChapter.handleLayerChange()
            
            return nil
        }
        
        // Add handleLayerChange
        compiler.register(name: "triggerEvent", parameterNames: ["theme", "key", "category", "take"], parameterTypes: [.int, .string, .string, .bool]) { parameters in
            
            if let theme = parameters["theme"] {
                let currentTheme = MangaBook.shared.getStateInt(key: "Theme")
                if theme.int == 0 || theme.int == currentTheme {
                    if let key = parameters["key"] {
                        if let category = parameters["category"] {
                            if let take = parameters["take"] {
                                if let item = MangaBook.shared.takeRandomItem(category: category.string, for: key.string, addToInventory: take.bool) {
                                    MangaBook.shared.lastItem = item
                                    MangaWorks.runGraceScript(item.onAquire)
                                }
                            }
                        }
                    }
                }
            }
            
            return nil
        }
        
        // Add handleLayerChange
        compiler.register(name: "triggerNamedEvent", parameterNames: ["theme", "key", "id", "take"], parameterTypes: [.int, .string, .string, .bool]) { parameters in
            
            if let theme = parameters["theme"] {
                let currentTheme = MangaBook.shared.getStateInt(key: "Theme")
                if theme.int == 0 || theme.int == currentTheme {
                    if let key = parameters["key"] {
                        if let id = parameters["id"] {
                            if let take = parameters["take"] {
                                if let item = MangaBook.shared.takeItem(id: id.string, for: key.string, addToInventory: take.bool) {
                                    MangaBook.shared.lastItem = item
                                }
                            }
                        }
                    }
                }
            }
            
            return nil
        }
        
        // Add triggerEventOnCount: this triggers the event ever fourth time the player crosses it.
        compiler.register(name: "triggerEventOnCount", parameterNames: ["theme", "key", "category", "take"], parameterTypes: [.int, .string, .string, .bool]) { parameters in
            
            if let theme = parameters["theme"] {
                let currentTheme = MangaBook.shared.getStateInt(key: "Theme")
                if theme.int == 0 || theme.int == currentTheme {
                    if let key = parameters["key"] {
                        if let category = parameters["category"] {
                            if let take = parameters["take"] {
                                let trigger = "\(key.string)Count"
                                var count = MangaBook.shared.getStateInt(key: trigger)
                                if count == 0 {
                                    if let item = MangaBook.shared.takeRandomItem(category: category.string, for: key.string, addToInventory: take.bool, ignoreTriggerState: true) {
                                        MangaBook.shared.lastItem = item
                                        MangaWorks.runGraceScript(item.onAquire)
                                    }
                                }
                                
                                count += 1
                                if count >= 30 {
                                 count = 0
                                }
                                MangaBook.shared.setState(key: trigger, value: count)
                            }
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    /// Handles the layer changing on a page.
    public static func handleLayerChange() {
        let page = MangaBook.shared.currentPage
        
        Execute.onMain {
            switch MangaBook.shared.layerVisibility {
            case MangaLayerManager.ElementVisibility.displayNextLocation:
                // Change Location??
                break
            case MangaLayerManager.ElementVisibility.displayConversationA:
                //dataStore.inlineConversation = .displayConversationA
                if MangaStateManager.autoReadPage {
                    if let conversation = page.conversationA {
                        let phrase = MangaWorks.expandMacros(in: conversation.message)
                        MangaPage.sayPhrase(phrase, inVoice: conversation.actor)
                    }
                }
            case MangaLayerManager.ElementVisibility.displayConversationB:
                //dataStore.inlineConversation = .displayConversationB
                if MangaStateManager.autoReadPage {
                    if let conversation = page.conversationB {
                        let phrase = MangaWorks.expandMacros(in: conversation.message)
                        MangaPage.sayPhrase(phrase, inVoice: conversation.actor)
                    }
                }
            default:
                // Read all visible text on the page
                if MangaStateManager.autoReadPage {
                    //page.readText(for: MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw)
                }
            }
        }
    }
    
    // MARK: - Properties
    /// The chapter's unique ID.
    public var id:String = ""
    
    /// Holds the title of the chapter.
    public var title:String = ""
    
    /// If `true` this `MangaChapter` can be purged when not in use.
    public var isPurgable:Bool = true
    
    /// A collection of pages held in this chapter.
    public var pages:[MangaPage] = []
    
    // MARK: - Computed Properties
    /// Return the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.chapter)
            .append(id)
            .append(title)
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
    ///   - title: The title of the chapter.
    ///   - isPurgable: If `true` this `MangaChapter` can be purged when not in use.
    public init(id: String, title:String, isPurgable:Bool = true) {
        self.id = id
        self.title = title
        self.isPurgable = isPurgable
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.chapter)
        
        self.id = deserializer.string()
        self.title = deserializer.string()
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
    /// - Returns: Returns the newly created page.
    @discardableResult public func addPage(id:String, pageType:MangaPage.PageType, imageName:String = "", title:String = "", pageNumber:Int = 0, previousPage:String = "", nextPage:String = "", showStats:Bool = false, endGame:Bool = false, suppressReadings:Bool = false, map:String = "", blueprint:String = "", loadResourceTag:String = "", releaseResourceTag:String = "", prefetchResourceTag:String = "", hintTag:String = "") -> MangaPage {
        
        // Get the page number.
        var num:Int = pageNumber
        if num == 0 {
            num = MangaBook.shared.totalPageCount
        }
        
        // Make a new page
        let page = MangaPage(id: id, pageType: pageType, imageName: imageName, chapter: self.id, title: title, pageNumber: num, previousPage: previousPage, nextPage: nextPage, showStats: showStats, endGame: endGame, suppressReadings: suppressReadings, map: map, blueprint: blueprint, loadResourceTag: loadResourceTag, releaseResourceTag: releaseResourceTag, prefetchResourceTag: prefetchResourceTag, hintTag: hintTag)
        
        // Add to collection.
        pages.append(page)
        
        return page
    }
}
