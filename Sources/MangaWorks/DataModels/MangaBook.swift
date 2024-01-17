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
import ODRManager

/// Holds all information about a `MangaBook` and the player's game state within the Manga based game.
@Observable open class MangaBook: SimpleSerializeable {
    
    // MARK: - Events
    /// Handle the MangaBook requesting a page from external storage.
    public typealias RequestExternalPage = (String) -> MangaPage?
    
    /// Handle the MangaBook requesting a chapter from external storage.
    public typealias RequestExternalChapter = (String) -> MangaChapter?
    
    /// Handle the MangaBook requesting the app display a `MangaPage`.
    public typealias RequestDisplayPage = (MangaPage) -> Void
    
    /// Handle the MangaBook requesting the app to change views.
    public typealias RequestChangeView = (String) -> Void
    
     /// Handles a generic event for the MangaBook.
    public typealias EventHandler = () -> Void
    
    // MARK: - Static Properties
    /// A shared instance of the `MangaBook` object.
    public static var shared:MangaBook = MangaBook()
    
    /// If `true`, the collection of `MangaChapters` will be included in the serialized results.
    public static var serializeStateOnly:Bool = true
    
    /// If `true` show hints on Manga Pages where they exist.
    public static var showHints:Bool = false
    
    // MARK: - Static Functions
    /// Registers `MangaBook` functions with the Grace Language so they are available in MangaWorks Grace Scripts.
    public static func registerGraceFunctions() {
        let compiler = GraceCompiler.shared
        
        // Add getState.
        compiler.register(name: "getState", parameterNames: ["key"], parameterTypes: [.string], returnType: .string) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                value = MangaBook.shared.getStateString(key: key.string)
            }
            
            return GraceVariable(name: "result", value: value, type: .string)
        }
        
        // Add getStateInt.
        compiler.register(name: "getStateInt", parameterNames: ["key"], parameterTypes: [.string], returnType: .int) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                value = MangaBook.shared.getStateString(key: key.string)
            }
            
            return GraceVariable(name: "result", value: value, type: .int)
        }
        
        // Add getStateDouble.
        compiler.register(name: "getStateDouble", parameterNames: ["key"], parameterTypes: [.string], returnType: .float) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                value = MangaBook.shared.getStateString(key: key.string)
            }
            
            return GraceVariable(name: "result", value: value, type: .float)
        }
        
        // Add getStateDouble.
        compiler.register(name: "getStateBool", parameterNames: ["key"], parameterTypes: [.string], returnType: .bool) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                value = MangaBook.shared.getStateString(key: key.string)
            }
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add setState
        compiler.register(name: "setState", parameterNames: ["key", "value"], parameterTypes: [.string, .any]) { parameters in
            
            if let key = parameters["key"] {
                if let value = parameters["value"] {
                    MangaBook.shared.setStateString(key: key.string, value: value.string)
                }
            }
            
            return nil
        }
        
        // Add returnToLastPage
        compiler.register(name: "returnToLastPage", parameterNames: [], parameterTypes: []) { parameters in
            
            MangaBook.shared.returnToLastView()
            
            return nil
        }
        
        // Add returnToLastPage
        compiler.register(name: "startNewGame", parameterNames: [], parameterTypes: []) { parameters in
            
            MangaBook.shared.startNewGame()
            
            return nil
        }
        
        // Add hasGameStarted
        compiler.register(name: "hasGameStarted", parameterNames: [], parameterTypes: [], returnType: .bool) { parameters in
            var value = ""
            
            value = "\(MangaBook.shared.startedReading)"
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add setState
        compiler.register(name: "setGameStarted", parameterNames: ["value"], parameterTypes: [.bool]) { parameters in
            
            if let value = parameters["value"] {
                MangaBook.shared.startedReading = value.bool
            }
            
            return nil
        }
        
        // Add adjustIntState
        compiler.register(name: "adjustIntState", parameterNames: ["key", "value"], parameterTypes: [.string, .int]) { parameters in
            
            if let key = parameters["key"] {
                if let value = parameters["value"] {
                    let num:Int = MangaBook.shared.getStateInt(key: key.string) + value.int
                    MangaBook.shared.setStateInt(key: key.string, value: num)
                }
            }
            
            return nil
        }
        
        // Add adjustDoubleState
        compiler.register(name: "adjustDoubleState", parameterNames: ["key", "value"], parameterTypes: [.string, .int]) { parameters in
            
            if let key = parameters["key"] {
                if let value = parameters["value"] {
                    let num:Double = MangaBook.shared.getStateDouble(key: key.string) + Double(value.float)
                    MangaBook.shared.setStateDouble(key: key.string, value: num)
                }
            }
            
            return nil
        }
        
        // Add changePage
        compiler.register(name: "changePage", parameterNames: ["id"], parameterTypes: [.string]) { parameters in
            
            if let id = parameters["id"] {
                MangaBook.shared.displayPage(id: id.string)
            }
            
            return nil
        }
        
        // Add changeView
        compiler.register(name: "changeView", parameterNames: ["id"], parameterTypes: [.string]) { parameters in
            
            if let id = parameters["id"] {
                MangaBook.shared.changeView(viewID: id.string)
            }
            
            return nil
        }
        
        // Add changeView
        compiler.register(name: "continueGame", parameterNames: [], parameterTypes: []) { parameters in
            
            MangaBook.shared.continueGame()
            
            return nil
        }
        
        // Add changeLayerVisibility (takes an integer)
        compiler.register(name: "changeLayerVisibility", parameterNames: ["visibility"], parameterTypes: [.string]) { parameters in
            
            if let visibility = parameters["visibility"] {
                MangaBook.shared.changeLayerVisibility(visibility: visibility.int)
            }
            
            return nil
        }
        
        // Add setLayerVisibility (takes a string)
        compiler.register(name: "setLayerVisibility", parameterNames: ["visibility"], parameterTypes: [.string]) { parameters in
            
            if let visibility = parameters["visibility"] {
                MangaBook.shared.changeLayerVisibility(visibility: visibility.string)
            }
            
            return nil
        }
        
        // Add containsItem.
        compiler.register(name: "containsItem", parameterNames: ["key"], parameterTypes: [.string], returnType: .bool) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                let result = MangaBook.shared.containsItem(id: key.string)
                value = "\(result)"
            }
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add takeItem
        compiler.register(name: "takeItem", parameterNames: ["key"], parameterTypes: [.string]) { parameters in
            
            if let key = parameters["key"] {
                MangaBook.shared.takeItem(id: key.string)
            }
            
            return nil
        }
        
        // Add dropItem
        compiler.register(name: "dropItem", parameterNames: ["key", "page"], parameterTypes: [.string, .string]) { parameters in
            
            if let key = parameters["key"] {
                if let page = parameters["page"] {
                    MangaBook.shared.dropItem(id: key.string, in: page.string)
                }
            }
            
            return nil
        }
        
        // Add useItem
        compiler.register(name: "useItem", parameterNames: ["key"], parameterTypes: [.string]) { parameters in
            
            if let key = parameters["key"] {
                MangaBook.shared.useItem(id: key.string)
            }
            
            return nil
        }
        
        // Add notTriggered.
        compiler.register(name: "notTriggered", parameterNames: ["key"], parameterTypes: [.string], returnType: .bool) { parameters in
            var value = ""
            
            if let key = parameters["key"] {
                let result = MangaBook.shared.notTriggered(mangaPageID: key.string)
                value = "\(result)"
            }
            
            return GraceVariable(name: "result", value: value, type: .bool)
        }
        
        // Add trigger
        compiler.register(name: "trigger", parameterNames: ["key"], parameterTypes: [.string]) { parameters in
            
            if let key = parameters["key"] {
                MangaBook.shared.trigger(mangaPageID: key.string)
            }
            
            return nil
        }
        
        // Add takeRandomItem
        compiler.register(name: "takeRandomItem", parameterNames: ["key"], parameterTypes: [.string]) { parameters in
            
            if let key = parameters["key"] {
                MangaBook.shared.takeRandomItem(for: key.string)
            }
            
            return nil
        }
        
        // Add saveNotebookEntry
        compiler.register(name: "saveNotebookEntry", parameterNames: ["notebookID", "image", "title", "entry"], parameterTypes: [.string, .string, .string, .string]) { parameters in
            
            if let notebookID = parameters["notebookID"] {
                if let image = parameters["image"] {
                    if let title = parameters["title"] {
                        if let entry = parameters["entry"] {
                            MangaBook.shared.notebook.saveEntry(notebookID: notebookID.string, image: image.string, title: title.string, entry: entry.string)
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    // MARK: - Enumerations
    /// Defines the source for the Manga Pages held in the book.
    public enum PageSource: Int {
        /// The pages as stored in internal memory.
        case internalStorage = 0
        
        /// The pages are stored in an external source.
        /// - Remark: The `onRequestExternalPage` property MUST be defined to handle requests for pages.
        case externalStorage
        
        /// The chapters are created when a page in that chapter is requested. All other purgable chapters will be released when a new chapter is loaded.
        case justInTimeStorage
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `internalStorage` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = PageSource(rawValue: value) {
                self = enumeration
            } else {
                self = .internalStorage
            }
        }
    }
    
    // MARK: - Properties
    /// Defines there the MangaBook's pages are stored.
    public var pageSource:PageSource = .internalStorage
    
    /// If `true`, the user has started reading this MangaBook
    public var startedReading:Bool = false
    
    /// The Id of the page currently being displayed.
    public var currentPageID:String = ""
    
    /// The id of the last page that was read.
    public var lastPageStack:[String] = []
    
    /// A collection of user state variables.
    public var state:[String:String] = [:]
    
    /// A notebook of notes collected by the user.
    public var notebook:MangaNotebook = MangaNotebook()
    
    /// A collection of inventory items that can be on a given `MangaPage` ir being carried by the player.
    public var items:[MangaInventoryItem] = []
    
    /// A collection of chapters in the book.
    public var chapters:[MangaChapter] = []
    
    /// Holds an instnace of the last page loaded.
    public var currentPage:MangaPage = MangaPage(id: "00", pageType: .fullPageImage)
    
    /// A collection of menu items that will be represented by the action menu.
    public var actionMenuItems:[MangaPageAction] = []
    
    /// Holds the current layervisibility for the panels and panorama viewers.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .empty
    
    /// Holds the results of an inline conversation.
    public var conversationResult1:String = ""
    
    /// Holds the results of an inline conversation.
    public var conversationResult2:String = ""
    
    /// Holds the results of an inline conversation.
    public var conversationResult3:String = ""
    
    /// A notification to display in the simulated iPhone on the landscape view.
    public var simulatediPhoneNotification:MangaDashboardNotification? = nil
    
    // MARK: - Events
    /// Handle the user wanting to load an external page.
    public var onRequestExternalPage:RequestExternalPage? = nil
    
    /// Handle the user requesting an external chapter.
    public var onRequestExternalChapter:RequestExternalChapter? = nil
    
    /// Handle the user wanting to display a page.
    public var onRequestDisplayPage:RequestDisplayPage? = nil
    
    /// Handle the user wanting to change views.
    public var onRequestChangeView:RequestChangeView? = nil
    
    /// Handle the player starting a new game.
    public var onStartNewGame:EventHandler? = nil
    
    /// Handle the player loading an existing game.
    public var onRestoreGameState:EventHandler? = nil
    
    /// Handle the player saving the game state.
    public var onSaveState:EventHandler? = nil
    
    // MARK: - Computed Properties
    /// Returns the total number of pages in the book.
    public var totalPageCount:Int {
        var pages = 0
        
        for chapter in chapters {
            pages += chapter.pages.count
        }
        
        return pages
    }
    
    /// Return the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.mangaBook)
            .append(startedReading)
            .append(currentPageID)
            .append(array: lastPageStack, divider: ",")
            .append(dictionary: state)
            .append(notebook)
            .append(children: items, divider: Divider.items)
        
        if !MangaBook.serializeStateOnly {
            serializer.append(children: chapters, divider: Divider.chapters)
            serializer.append(children: actionMenuItems, divider: Divider.pageActions)
        }
        
        return serializer.value
    }
    
    // MARK: - Initializers
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        self.load(from: value)
    }
    
    // MARK: - Functions
    // !!!: - State Management
    /// Loads the state from a serialized string.
    /// - Parameter value: A serialized string representing the object.
    public func load(from value:String) {
        
        // Request to "start" a new game so all the state only items are build before being loaded
        // and restored from storage.
        if let onRestoreGameState {
            onRestoreGameState()
        }
        
        guard value != "" else {
            return
        }
        
        let deserializer = Deserializer(text: value, divider: Divider.mangaBook)
        
        self.startedReading = deserializer.bool()
        self.currentPageID = deserializer.string()
        self.lastPageStack = deserializer.array(divider: ",")
        self.state = deserializer.dictionary()
        self.notebook = deserializer.child()
        
        if MangaInventoryItem.serializeStateOnly {
            let states:[MangaInventoryItem] = deserializer.children(divider: Divider.items)
            self.mergeStateWithItems(states)
        } else {
            self.items = deserializer.children(divider: Divider.items)
        }
        
        if !MangaBook.serializeStateOnly {
            self.chapters = deserializer.children(divider: Divider.chapters)
            self.actionMenuItems = deserializer.children(divider: Divider.pageActions)
        }
    }
    
    /// Merges the state of inventory items that have been serialized with the full item description.
    /// - Parameter states: The states read from the serialized string.
    private func mergeStateWithItems(_ states:[MangaInventoryItem]) {
        for state in states {
            if let item = getItem(id: state.id) {
                item.status = state.status
                item.mangaPageID = state.mangaPageID
                item.quantityRemaining = state.quantityRemaining
            }
        }
    }
    
    /// Starts a new game.
    public func startNewGame() {
        self.startedReading = true
        self.currentPageID = ""
        self.lastPageStack = []
        self.state = [:]
        self.notebook = MangaNotebook()
        self.items = []
        self.chapters = []
        self.currentPage = MangaPage(id: "00", pageType: .fullPageImage)
        
        // Does the hosting app need to setup a new game?
        guard let onStartNewGame else {
            return
        }
        
        // Yes, allow the host to configure the game.
        onStartNewGame()
    }
    
    // !!!: - Action Menue
    /// Adds a new action menu item to the MangaBook.
    /// - Parameters:
    ///   - text: The text description of the action.
    ///   - condition: A condition that must evaluate to `true` written as a Grace Language macro.
    ///   - excute: The Grace Language script to run when the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addActionMenuItem(text:String, condition:String = "", excute:String = "") -> MangaBook {
        let id:Int = actionMenuItems.count
        let action = MangaPageAction(id: id, text: text, condition: condition, excute: excute)
        actionMenuItems.append(action)
        
        return self
    }
    
    // !!!: - Inventory Items
    /// Returns all of the items that are currently in the player's inventory.
    /// - Returns: Returns a collection of items the player is carrying.
    public func playerInventory() -> [MangaInventoryItem] {
        var inventory:[MangaInventoryItem] = []
        
        for item in items {
            if item.status == .inPlayerInventory {
                inventory.append(item)
            }
        }
        
        return inventory
    }
    
    /// Gets an item from the inventory item collection by id.
    /// - Parameter id: The id of the item to load.
    /// - Returns: Returns the item if found else returns `nil`
    public func getItem(id:String) -> MangaInventoryItem? {
        for item in items {
            if item.id == id {
                return item
            }
        }
        
        // Not found
        return nil
    }
    
    /// Checks to see if the given item is hidden on a Manga Page.
    /// - Parameter id: THe id of the item to check.
    /// - Returns: Returns `true` if the item is hidden on a page, else returns false.
    public func containsItem(id:String) -> Bool {
        
        if let item = getItem(id: id) {
            return item.status == .hiddenOnMangaPage
        }
        
        // Not found
        return false
    }
    
    /// Takes an item from a `MangaPage` and places it in the player's inventory.
    /// - Parameter id: The id of the item to take.
    public func takeItem(id:String) {
        
        // Ensure the item can be found.
        guard let item = getItem(id: id) else {
            return
        }
        
        // Place the item in the player's inventory
        item.status = .inPlayerInventory
        item.mangaPageID = ""
        
        // Execute acquire script
        MangaWorks.runGraceScript(item.onAquire)
    }
    
    /// Removes the given item from the player's inventory and places it in the current room.
    /// - Parameters:
    ///   - id: The id of the item to drop.
    ///   - mangaPageID: The room to drop the item in.
    public func dropItem(id:String, in mangaPageID:String) {
        
        // Ensure the item can be found.
        guard let item = getItem(id: id) else {
            return
        }
        
        // Remove the item and drop it in the page.
        item.status = .droppedOnMangaPage
        item.mangaPageID = mangaPageID
        
        // Execute lost script
        MangaWorks.runGraceScript(item.onLost)
    }
    
    /// Uses the current item.
    /// - Parameter id: The id of the item to use.
    public func useItem(id:String) {
        
        // Ensure the item can be found.
        guard let item = getItem(id: id) else {
            return
        }
        
        // Execute use script
        MangaWorks.runGraceScript(item.onUse)
    }
    
    /// Checks to see if a random inventory spot has been triggered.
    /// - Parameter mangaPageID: The ID of the manga page checking for a trigger.
    /// - Returns: Returns `true` if the item interaction has not been used, else returns `false`.
    public func notTriggered(mangaPageID:String) -> Bool {
        let key = "triggered\(mangaPageID)"
        
        return !getStateBool(key: key)
    }
    
    /// Triggers a random inventory item for a given manga page.
    /// - Parameter mangaPageID: The id of the manga page to trigger.
    public func trigger(mangaPageID:String) {
        let key = "triggered\(mangaPageID)"
        setStateBool(key: key, value: true)
    }
    
    /// Takes the next random unused item.
    /// - Parameter mangaPageID: The ID of the page that the item is being taken from.
    public func takeRandomItem(for mangaPageID:String) {
        
        // Mark as used.
        trigger(mangaPageID: mangaPageID)
        
        // Shuffle items
        items.shuffle()
        
        // Find the next unsed item and add it to the inventory
        for item in items {
            if item.status == .unAssigned {
                takeItem(id: item.id)
                return
            }
        }
    }
    
    // !!!: - Notes
    /// Saves an entry to the notebook.
    /// - Parameters:
    ///   - notebookID: The ID of the entry to save.
    ///   - image: An image for the entry.
    ///   - title: The title of the entry.
    ///   - entry: The body of the entry.
    public func addNote(notebookID: String = "", image: String = "", title: String = "", entry: String = "") {
        notebook.saveEntry(notebookID: notebookID, image: image, title: title, entry: entry)
        simulatediPhoneNotification = MangaDashboardNotification(icon: "book.pages.fill", title: "New Note", description: "A new note has been added to your notebook.")
    }
    
    // !!!: - Chanpters
    /// Returns the given chapter.
    /// - Parameter id: The id of the chapter to return.
    /// - Returns: Returns the requested chapter or `nil` if not found.
    public func getChapter(id:String) -> MangaChapter? {
        
        // Scan all chapters
        for chapter in chapters {
            if chapter.id == id {
                return chapter
            }
        }
        
        // Are chapters built just in time?
        if pageSource == .justInTimeStorage {
            // Release any purgable chapters.
            releasePurgableChapters()
            
            // Yes, request the chapter be built
            if let onRequestExternalChapter {
                return onRequestExternalChapter(id)
            }
        }
        
        // Not found
        return nil
    }
    
    /// Release all purgable chapters from memory.
    public func releasePurgableChapters() {
        var n = chapters.count - 1
        
        // Scan all chapters.
        while n >= 0 {
            // Is this chapter purgable?
            if chapters[n].isPurgable {
                // Yes, remove it from memory.
                chapters.remove(at: n)
            }
            
            n -= 1
        }
    }
    
    /// Returns an existing or creates a new chapter.
    /// - Parameters:
    ///   - id: The id of the chapter to fetch or create.
    ///   - isPurgable: If `true` this `MangaChapter` can be purged when not in use.
    /// - Returns: Returns the requested chapter.
    private func newOrExistingChapter(id:String, isPurgable:Bool = true) -> MangaChapter {
        // Scan all chapters.
        for chapter in chapters {
            if chapter.id == id {
                return chapter
            }
        }
        
        // Create, store and return new chapter.
        let chapter = MangaChapter(id: id, isPurgable: isPurgable)
        chapters.append(chapter)
        return chapter
    }
    
    /// Creates a new chapter if it does not already exist.
    /// - Parameters:
    ///   - id: The unique ID of the chapter.
    ///   - isPurgable: If `true` this `MangaChapter` can be purged when not in use.
    /// - Returns: Returns the new chapter.
    public func addChapter(id: String, isPurgable:Bool = true) -> MangaChapter {
        return newOrExistingChapter(id: id, isPurgable: isPurgable)
    }
    
    // !!!: - Pages
    /// Gets the requested page.
    /// - Parameter id: The ID of the page to return.
    /// - Returns: Returns the requested page or `nil` if the page is not found.
    public func getPage(id:String) -> MangaPage? {
        var chapterID:String = ""
        var pageID:String = id
        
        // Does the id include a chapter?
        if id.contains("|") {
            let parts = id.split(separator: "|")
            chapterID = String(parts[0])
            pageID = String(parts[1])
        }
        
        // Take action based on the source
        switch pageSource {
        case .justInTimeStorage:
            if let chapter = getChapter(id: chapterID) {
                return chapter.getPage(id: pageID)
            }
        case .externalStorage:
            if let onRequestExternalPage {
                return onRequestExternalPage(pageID)
            }
        case .internalStorage:
            // Does the id include a chapter?
            if chapterID != "" {
                if let chapter = getChapter(id: chapterID) {
                    return chapter.getPage(id: pageID)
                }
            } else {
                // Scan all chapters.
                for chapter in chapters {
                    if let page = chapter.getPage(id: pageID) {
                        return page
                    }
                }
            }
        }
        
        // Not found
        return nil
    }
    
    /// Adds a page to the given chapter. The chapter will be created if it does not already exist.
    /// - Parameters:
    ///   - chapter: The chapter to add the page to.
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
    @discardableResult public func addPage(chapter:String, id:String, pageType:MangaPage.PageType, imageName:String = "", title:String = "", pageNumber:Int = 0, previousPage:String = "", nextPage:String = "", showStats:Bool = false, endGame:Bool = false, suppressReadings:Bool = false, map:String = "", blueprint:String = "", loadResourceTag:String = "", releaseResourceTag:String = "", prefetchResourceTag:String = "", hintTag:String = "") -> MangaBook {
        
        let chapter = newOrExistingChapter(id: chapter)
        chapter.addPage(id: id, pageType: pageType, imageName: imageName, title: title, pageNumber: pageNumber, previousPage: previousPage, nextPage: nextPage, showStats: showStats, endGame: endGame, suppressReadings: suppressReadings, map: map, blueprint: blueprint, loadResourceTag: loadResourceTag, releaseResourceTag: releaseResourceTag, prefetchResourceTag: prefetchResourceTag, hintTag: hintTag)
        
        return self
    }
    
    // !!!: - View Handlers
    /// Request the app to change view.
    /// - Parameter viewID: The id of the view to display.
    public func changeView(viewID:String) {
        if let onRequestChangeView {
            Execute.onMain {
                // Ask app to change views.
                onRequestChangeView(viewID)
            }
        } else {
            Debug.error(subsystem: "MangaWorks", category: "Change View", "ERRROR: onRequestChangeView not defined.")
        }
    }
    
    /// Returns to the last page viewed.
    public func returnToLastView() {
        
        // Ensure a last page exists.
        guard currentPageID != "" else {
            return
        }
        
        // Take action based on the page type
        switch currentPage.pageType {
        case .fullPageImage:
            changeView(viewID: "[FULLPAGE]")
        case .panelsPage:
            changeView(viewID: "[PANELPAGE]")
        case .panoramaPage:
            changeView(viewID: "[PANOPAGE]")
        }
        
    }
    
    /// Request that the app changes the layer visibility.
    /// - Parameter visibility: The visibility as a string.
    public func changeLayerVisibility(visibility:String) {
        var value:MangaLayerManager.ElementVisibility = .empty
        value.from(visibility)
        changeLayerVisibility(visibility: value)
    }
    
    /// Request that the app changes the layer visibility.
    /// - Parameter visibility: The visibility as an int.
    public func changeLayerVisibility(visibility:Int) {
        var value:MangaLayerManager.ElementVisibility = .empty
        value.from(visibility)
        changeLayerVisibility(visibility: value)
    }
    
    /// Request that the app changes the layer visibility.
    /// - Parameter visibility: The new layer visibility.
    public func changeLayerVisibility(visibility:MangaLayerManager.ElementVisibility) {
        layerVisibility = visibility
    }
    
    /// Pushes the id of the last page visited onto the stack.
    /// - Parameter id: The id of the last page visited.
    public func pushLastPage(id:String) {
        
        // Ensure the ID is not empty.
        guard id != "" else {
            return
        }
        
        // Ensure this is not a control page.
        guard !currentPageID.contains("*") else {
            return
        }
        
        // Add the ID to the stack.
        if lastPageStack.count == 0 {
            lastPageStack.append(id)
        } else {
            lastPageStack.insert(id, at: 0)
        }
        
        // Only save the last ten pages
        if lastPageStack.count >= 10 {
            lastPageStack.remove(at: 9)
        }
    }
    
    /// Pops the id of the previous page visited off of the stack.
    /// - Returns: Returns the last page id or "" if no last pages exist.
    public func popLastPageID() -> String {
        
        guard lastPageStack.count > 0 else {
            return ""
        }
        
        let id = lastPageStack[0]
        lastPageStack.remove(at: 0)
        
        return id
    }
    
    /// Ask the app to display a given `MangaPage`.
    /// - Parameter id: The id of the page to display.
    public func displayPage(id:String) {
        var newPageID = id
        
        // Special processing?
        switch newPageID {
        case "<<":
            newPageID = popLastPageID()
        case "[CURRENT]":
            newPageID = "\(currentPage.chapter)|\(currentPage.id)"
        case "[COVER]":
            changeView(viewID: "[COVER]")
            return
        default:
            break
        }
        
        // Anything to process?
        guard newPageID != "" else {
            return
        }
        
        // Ensure that the page can be found.
        guard let page = getPage(id: MangaWorks.expandMacros(in: newPageID)) else {
            Debug.error(subsystem: "MangaWorks", category: "Display Page", "ERROR: Page '\(id)' not found.")
            return
        }
        
        // Clear any existing notification
        simulatediPhoneNotification = nil
        
        // Add any notes
        if page.note.notebookID != "" {
            addNote(notebookID: page.note.notebookID, image: page.note.image, title: page.note.title, entry: page.note.entry)
        }
        
        // Save last location
        pushLastPage(id: currentPageID)
        
        // Save the last page loaded
        currentPage = page
        
        // Save Current Page ID
        let pageID = "\(page.chapter)|\(page.id)"
        currentPageID = pageID
        
        // Request to save state
        requestSaveState()
        
        // Load any on demand resources for this page.
        OnDemandResources.loadResourceTag = MangaWorks.expandMacros(in: page.loadResourceTag)
        ODRManager.shared.requestResourceWith(tag: OnDemandResources.loadResourceTag, onLoadingResource: {
                Debug.info(subsystem: "MasterDataStore", category: "On Demand Resource", "Loading: \(OnDemandResources.loadResourceTag)")
                OnDemandResources.lastResourceLoadError = ""
                OnDemandResources.isLoadingResouces = true
            }, onSuccess: {
                Debug.info(subsystem: "MasterDataStore", category: "On Demand Resource", "Content Loaded: \(OnDemandResources.loadResourceTag)")
                OnDemandResources.lastResourceLoadError = ""
                OnDemandResources.isLoadingResouces = false
                
                self.finishLoadingPage(page)
            }, onFailure: {error in
                Log.error(subsystem: "MasterDataStore", category: "On Demand Resource", "Error: \(OnDemandResources.loadResourceTag) = \(error)")
                OnDemandResources.lastResourceLoadError = error
                
                // NOTE: Marking `isLoadingResouces` `true` so that the error can be displayed using a `ODRContentLoadingOverlay` in our UI
                OnDemandResources.isLoadingResouces = true
            })
        
        // Release any required resources
        ODRManager.shared.releaseResourceWith(tag: MangaWorks.expandMacros(in: page.releaseResourceTag))
        
        // Prefecth any specified resources
        ODRManager.shared.prefetchResourceWith(tag: MangaWorks.expandMacros(in: page.prefetchResourceTag))
    }
    
    /// Finalizes the loading of the page and asks the app to display it.
    /// - Parameter page: The page to finish loading.
    private func finishLoadingPage(_ page:MangaPage) {
        
        // Has hints?
        if MangaBook.showHints && page.hintTag != "" {
            SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Jingle_Win_Synth_00", ofType: "mp3"), channel: .channel04)
        }
        
        // Read page?
        if MangaStateManager.autoReadPage {
            page.readText(invisibleText: false)
        }
        
        // Start the sound effects for the current page.
        page.startLocationSounds()
        
        // Execute any startup scripts
        MangaWorks.runGraceScript(page.onLoadAction)
        
        // Request the app to show the page
        if let onRequestDisplayPage {
            Execute.onMain {
                onRequestDisplayPage(page)
            }
        } else {
            Debug.error(subsystem: "MangaWorks", category: "Display Page", "Error: onRequestDisplayPage has not been defined.")
        }
    }
    
    // !!!: - Game State Management
    /// Request the app to save the current game state.
    public func requestSaveState() {
        
        guard let onSaveState else {
            return
        }
        
        onSaveState()
    }
    
    /// Continues an already started game.
    public func continueGame() {
        
        if currentPageID.contains("*") {
            currentPageID = popLastPageID()
        }
        
        guard currentPageID != "" else {
            changeView(viewID: "[COVER]")
            return
        }
        
        displayPage(id: currentPageID)
    }
    
    /// Generates a random "PIN" that can be used for passcodes in the game.
    /// - Parameter digits: The number of digits in the code.
    /// - Returns: A random string of numbers
    public func buildPIN(digits:Int = 6) -> String {
        var pin = ""
        
        for _ in 1...digits {
            let digit = Int.random(in: 0...9)
            pin += "\(digit)"
        }
        
        return pin
    }
    
    /// Returns the state for the given key
    /// - Parameter key: The key to return.
    /// - Returns: Returns the requested string or "" if not found.
    public func getStateString(key:String) -> String {
        if let value = state[key] {
            return value
        } else {
            return ""
        }
    }
    
    /// Sets the state to the given value.
    /// - Parameters:
    ///   - key: The state key to set.
    ///   - value: The value to set the key to.
    public func setStateString(key:String, value:String) {
        state[key] = value
    }
    
    /// Gets the requested state value.
    /// - Parameter key: The key to return.
    /// - Returns: Returns to bool state or `false` if not found.
    public func getStateBool(key:String) -> Bool {
        let text = getStateString(key: key)
        
        if let value = Bool(text) {
            return value
        } else {
            return false
        }
    }
    
    /// Sets the state to the given value.
    /// - Parameters:
    ///   - key: The key to set.
    ///   - value: The new value.
    public func setStateBool(key:String, value:Bool) {
        setStateString(key: key, value: "\(value)")
    }
    
    /// Gets the given state value.
    /// - Parameter key: The key to get the value of.
    /// - Returns: Returns the int value or `0` if not found.
    public func getStateInt(key:String) -> Int {
        let text = getStateString(key: key)
        
        if let value = Int(text) {
            return value
        } else {
            return 0
        }
    }
    
    /// Sets the state the to given value.
    /// - Parameters:
    ///   - key: The key of the state to set.
    ///   - value: The new value.
    public func setStateInt(key:String, value:Int) {
        setStateString(key: key, value: "\(value)")
    }
    
    /// Gets the given state value.
    /// - Parameter key: The key to get the value of.
    /// - Returns: Returns the double value or `0` if not found.
    public func getStateDouble(key:String) -> Double {
        let text = getStateString(key: key)
        
        if let value = Double(text) {
            return value
        } else {
            return 0.0
        }
    }
    
    /// Sets the state the to given value.
    /// - Parameters:
    ///   - key: The key of the state to set.
    ///   - value: The new value.
    public func setStateDouble(key:String, value:Double) {
        setStateString(key: key, value: "\(value)")
    }
}
