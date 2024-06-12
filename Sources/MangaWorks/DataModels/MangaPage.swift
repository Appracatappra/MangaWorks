//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
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

/// Holds all of the information about a Manga Page that can be display and interacted with using MangaWorks tools.
open class MangaPage: Identifiable, SimpleSerializeable {
    
    // MARK: - Static Properties
    /// Defines the default background music that will be applied to any new location created.
    public nonisolated(unsafe) static var defaultBackgroundMusic:String = ""
    
    /// Defines the default background sound that will be applied to any new location created.
    public nonisolated(unsafe) static var defaultBackgroundSound:String = ""
    
    /// Defines the default weather that will be applied to any new location created.
    public nonisolated(unsafe) static var defaultWeather:WeatherSystem = .clear
    
    /// Defines the default level that will be applied to any new location created.
    public nonisolated(unsafe) static var defaultChapter:String = ""
    
    /// Defines the default resource tag that all locations will be loaded from.
    public nonisolated(unsafe) static var defaultLoadResourceTag:String = ""
    
    /// Defines the default resource tag that will be released for all locations.
    public nonisolated(unsafe) static var defaultReleaseResourceTag:String = ""
    
    /// Defines the default resource tag that will be prefetched for all locations.
    public nonisolated(unsafe) static var defaultPrefetchResourceTag:String = ""
    
    /// Defines the default for showning the functions menu in all locations.
    public nonisolated(unsafe) static var defaultHasFunctionsMenu:Bool = true
    
    /// Defines the default map for all locations.
    public nonisolated(unsafe) static var defaultMap:String = ""
    
    /// Defines the default blueprint for all locations.
    public nonisolated(unsafe)static var defaultBlueprint:String = ""
    
    // MARK: - Static Functions
    /// Return all of the default variables to there default settings.
    public static func resetDefaults() {
        MangaPage.defaultBackgroundMusic = ""
        MangaPage.defaultBackgroundSound = ""
        MangaPage.defaultWeather = .clear
        MangaPage.defaultChapter = ""
        MangaPage.defaultLoadResourceTag = ""
        MangaPage.defaultReleaseResourceTag = ""
        MangaPage.defaultPrefetchResourceTag = ""
        MangaPage.defaultHasFunctionsMenu = true
        MangaPage.defaultMap = ""
        MangaPage.defaultBlueprint = ""
    }
    
    // !!!: Text To Speach
    /// Reads the given text in the given voice.
    /// - Parameters:
    ///   - text: The text to read.
    ///   - inVoice: The voice to read the text in.
    @discardableResult static func sayPhrase(_ text:String, inVoice:MangaVoiceActors, shouldReadText:Bool = true) -> String {
        var expandedText:String = ""
        
        // Expand macros in text.
        do {
            expandedText = try GraceRuntime.shared.expandMacros(in: text)
        } catch {
            return text
        }
        
        // Should the text be read aloud?
        guard shouldReadText else {
            return text
        }
        
        // Tweak some words and phrases for speach synthesys.
        let phrase = expandedText.replacingOccurrences(of: "Cyberbrain", with: "Cyber-Brain")
        
        switch inVoice {
        case .narrator:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishAustralia)
        case .electronics:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishUnitedStates)
        case .maleOne:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishUnitedKingdom)
        case .maleTwo:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishIndia)
        case .femaleOne:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishSouthAfrica)
        case .femaleTwo:
            SpeechManager.shared.sayPhrase(phrase, inVoice: .englishIreland)
        }
        
        return text
    }
    
    /// Creates a Grace Script Program from the provided elements.
    /// - Parameters:
    ///   - soundEffect: The sound effect to play.
    ///   - Points: The game points to accrue.
    ///   - pageID: The ID of the Manga Page to display.
    ///   - visibility: A change in the layer visibility.
    /// - Returns: Returns a Grace Script build from the provided parts.
    public static func composeGraceScript(soundEffect:String = "", points:Int = 0, pageID:String = "", visibility:MangaLayerManager.ElementVisibility = .displayNothing) -> String {
        var script:String = ""
        
        // Open script
        script = "import StandardLib; import StringLib; main {"
        
        // Has sound effects?
        if soundEffect != "" {
            script += "call @playSoundEffect('\(soundEffect)', 4); "
        }
        
        // Modifies points?
        if points != 0 {
            script += "call @adjustIntState('Points', \(points), 0, 10000000); "
        }
        
        // Change page?
        if pageID != "" {
            script += "call @changePage('\(pageID)'); "
        }
        
        // Change layer visibility?
        if visibility != .displayNothing {
            script += "call @changeLayerVisibility(\(visibility.rawValue)); call @handleLayerChange();"
        }
        
        // Close script
        script += "}";
        
        return script
    }
    
    // MARK: - Enumerations
    /// Defines the type of weather occurring at a given location.
    public enum WeatherSystem: Int {
        /// For either an interior location or an outside location with no weather.
        case clear = 0
        
        /// Whie it's not raining at the current location, you can hear the rain.
        case rainNearby
        
        /// Whie it's not raining at the current location, you can hear the rain and see lightning.
        case rainAndLigntningNearby
        
        /// There is lightning at the current location
        case lightning
        
        // It is raining at the current location.
        case rain
        
        // There is both rain and fog at the current location.
        case rainAndFog
        
        // There is both rain and falling leaves at the current location.
        case rainAndFallingLeaves
        
        // There is both rain and blown paper at the current location.
        case rainAndPaper
        
        // There is fog at the given location.
        case fog
        
        // There is fog and lightning at the current location.
        case fogAndLightning
        
        // There are falling leaves here.
        case fallingLeaves
        
        // There are falling leaves and lightning here.
        case fallingLeavesAndLightning
        
        // This location is inside a city and has a storm.
        case cityStorm
        
        // This location is in a wooded area and has a storm.
        case parkStorm
        
        // This location has sparkles.
        case bokeh
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `clear` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = WeatherSystem(rawValue: value) {
                self = enumeration
            } else {
                self = .clear
            }
        }
    }
    
    /// Defines the type of page that a `MangaPage` is holding.
    public enum PageType: Int {
        /// The page is a simple full page image.
        case fullPageImage = 0
        
        /// The page is a collection of image panels.
        case panelsPage
        
        /// The page contains an interactive panorama.
        case panoramaPage
        
        // MARK: - Functions
        /// Gets the value from an `Int` and defaults to `clear` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = PageType(rawValue: value) {
                self = enumeration
            } else {
                self = .panelsPage
            }
        }
    }
    
    // MARK: - Properties
    /// The unique ID of the page.
    public var id:String = ""
    
    /// The type of page this `MangaPage` is representing.
    public var pageType:PageType = .panelsPage
    
    /// The name of the full page image or panorama image to be displayed.
    public var imageName:String = ""
    
    /// The type of weather occurring at the given page.
    public var weather:WeatherSystem = .clear
    
    /// The page's title.
    public var title:String = ""
    
    /// The page number.
    public var pageNumber:Int = 0
    
    /// The name of the background music that should be played for this page.
    public var backgroundMusic:String = ""
    
    /// The name of a background sound that should be played for this page.
    public var backgroundSound:String = ""
    
    /// The name of a sound effect that should be played when this page is first entered.
    public var soundEffect:String = ""
    
    /// The chapter for the page.
    public var chapter:String = ""
    
    /// Links to the previous panel page.
    public var previousPage:String = ""
    
    /// Links to the next panel page
    public var nextPage:String = ""
    
    /// Defines the resource tag that holds the resources required for this page.
    public var loadResourceTag:String = ""
    
    /// Defines the resource tag that should be released when this page loads.
    public var releaseResourceTag:String = ""
    
    /// Defines a resource tag that should be prefetched when this page loads.
    public var prefetchResourceTag:String = ""
    
    /// A collection of touch points for the page move image.
    public var zones:[MangaPageTouchZone] = []
    
    /// A collection of captions with placeholders for the given captions at each of the 12 possible placement locations.
    public var captions:[MangaPageCaption?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    /// A collection of balloons with placeholders for the given balloon at each of the 12 possible placement locations.
    public var balloons:[MangaPageSpeechBalloon?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    /// A collection of word art objects with placeholders for the given object at each of the 12 possible placement locations.
    public var wordArt:[MangaPageWordArt?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    /// A collection of detail images with placeholders for the given image at each of the 12 possible placement locations.
    public var detailImages:[MangaPageDetailImage?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    /// Holds all of the navigation points for this page.
    public var navigationPoints:[MangaPageNavigationPoint] = []
    
    /// Holds all of the interaction points for this page.
    public var interactions:[MangaPageInteraction] = []
    
    /// A collection of panels with placeholders for the given panel at each of the 12 possible placement locations.
    public var panels:[MangaPagePanel?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    /// A set of user interactions for this manga page.
    public var actions:MangaPageActions? = nil
    
    /// A set of manga page conversation options for the first slot.
    public var conversationA:MangaPageConversation? = nil
    
    /// A set of manga page conversation options for the second slot.
    public var conversationB:MangaPageConversation? = nil
    
    /// A pni entry for this manga page.
    public var pin:MangaPagePin? = nil
    
    /// A symbol entry for this manga page.
    public var symbol:MangaPageSymbol? = nil
    
    /// If `true` show the user stats.
    public var showStats:Bool = false
    
    /// If `true` end the game on this page.
    public var endGame:Bool = false
    
    /// A Grace Language script to run when this page loads.
    public var onLoadAction:String = ""
    
    /// If `true`, suppress reading this page aloud.
    public var suppressReading:Bool = false
    
    /// If `true`, this page has a functions menu.
    public var hasFunctionsMenu:Bool = true
    
    /// The hint tag for this page.
    public var hintTag:String = ""
    
    /// A collection of hints for this page.
    public var hints:[MangaPageHint] = []
    
    /// The map image for this page.
    public var map:String = ""
    
    /// The blueprint image for this page.
    public var blueprints:String = ""
    
    /// Holds any note attached to this location.
    public var note:MangaNotebookEntry = MangaNotebookEntry()
    
    /// Holds a potential NPC conversation for this location.
    public var npc:MangaPageNPC = MangaPageNPC(theme: 0, id: "", conversationPage: "")
    
    /// The last caption read.
    public var lastReadCaptions:String = ""
    
    /// The last balloons read.
    public var lastReadBallons:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.page)
            .append(id)
            .append(pageType)
            .append(imageName)
            .append(weather)
            .append(title)
            .append(pageNumber)
            .append(backgroundMusic)
            .append(backgroundSound)
            .append(soundEffect)
            .append(chapter)
            .append(previousPage)
            .append(nextPage)
            .append(loadResourceTag)
            .append(releaseResourceTag)
            .append(prefetchResourceTag)
            .append(children: zones, divider: Divider.pageElements)
            .append(children: captions, divider: Divider.pageElements)
            .append(children: balloons, divider: Divider.pageElements)
            .append(children: wordArt, divider: Divider.pageElements)
            .append(children: detailImages, divider: Divider.pageElements)
            .append(children: navigationPoints, divider: Divider.pageElements)
            .append(children: interactions, divider: Divider.pageElements)
            .append(children: panels, divider: Divider.pageElements)
            .append(actions)
            .append(conversationA)
            .append(conversationB)
            .append(pin)
            .append(symbol)
            .append(showStats)
            .append(endGame)
            .append(onLoadAction, isBase64Encoded: true)
            .append(suppressReading)
            .append(hasFunctionsMenu)
            .append(hintTag)
            .append(children: hints, divider: Divider.pageElements)
            .append(map)
            .append(blueprints)
            .append(note)
            .append(npc)
        
        return serializer.value
    }
    
    /// The move image name for the location.
    public var moveImageName:String {
        return "\(imageName)M"
    }
    
    /// Returns `true` if it is raining at the current location, else it returns `false`.
    public var hasRain:Bool {
        switch weather {
        case .rain, .rainAndFog, .rainAndFallingLeaves, .cityStorm, .rainAndPaper, .parkStorm:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if you can hear rain at the current location, else it returns `false`.
    public var hasRainSounds:Bool {
        switch weather {
        case .rainNearby, .rain, .rainAndFog, .rainAndFallingLeaves, .cityStorm, .rainAndLigntningNearby, .rainAndPaper, .parkStorm:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if it is lightning at the current location, else it returns `false`.
    public var hasLightning:Bool {
        switch weather {
        case .rain, .rainAndFog, .lightning, .fogAndLightning, .fallingLeavesAndLightning, .rainAndFallingLeaves, .cityStorm, .rainAndLigntningNearby, .rainAndPaper, .parkStorm:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if you can hear lightning with no rain at the current location, else it returns `false`.
    public var hasLightningSound:Bool {
        switch weather {
        case .lightning, .fogAndLightning, .fallingLeavesAndLightning:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if there is fog at the current location, else it returns `false`.
    public var hasFog:Bool {
        switch weather {
        case .fog, .rainAndFog, .fogAndLightning, .cityStorm, .parkStorm:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if there are falling leaves at the current location, else it returns `false`.
    public var hasFallingLeaves:Bool {
        switch weather {
        case .fallingLeaves, .fallingLeavesAndLightning, .rainAndFallingLeaves, .parkStorm:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if there are falling leaves at the current location, else it returns `false`.
    public var hasBlownPaper:Bool {
        switch weather {
        case .cityStorm, .rainAndPaper:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if this location has the bokeh effect.
    public var hasBokeh:Bool {
        switch weather {
        case .bokeh:
            return true
        default:
            return false
        }
    }
    
    /// Returns `true` if there is weather at the current location, else it returns `false`.
    public var hasWeather:Bool {
        switch weather {
        case .clear, .rainNearby:
            return false
        default:
            return true
        }
    }
    
    /// If `true` there is a NPC conversation at this location.
    public var hasNPC:Bool {
        
        if npc.id != "" {
            let theme = MangaBook.shared.getStateInt(key: "Theme")
            if npc.theme == 0 || npc.theme == theme {
                let npcID = MangaBook.shared.getStateString(key: npc.id)
                if npcID != "" {
                    if !MangaBook.shared.getStateBool(key: "\(npc.id)Dead") {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The unique page id.
    ///   - imageName: The image to show for the page.
    ///   - chapter: The chapther this page belongs to.
    ///   - title: The title for the page.
    ///   - pageNumber: The page number.
    ///   - previousPage: The previous page ID.
    ///   - nextPage: The next page ID.
    ///   - showStats: If `true` show stats on this page.
    ///   - endGame: If `true` end the game on this page.
    ///   - suppressReadings: If `true` suppress reading this page aloud.
    ///   - map: The map image for this page.
    ///   - blueprint: The blueprint image for this page.
    ///   - loadResourceTag: The ODR tag to load.
    ///   - releaseResourceTag: The ODR tag to release.
    ///   - prefetchResourceTag: The ODR tag to prefetch.
    ///   - hintTag: The hint tag.
    public init(id:String, pageType:PageType, imageName:String = "", chapter:String = "", title:String = "", pageNumber:Int = 0, previousPage:String = "", nextPage:String = "", showStats:Bool = false, endGame:Bool = false, suppressReadings:Bool = false, map:String = "", blueprint:String = "", loadResourceTag:String = "", releaseResourceTag:String = "", prefetchResourceTag:String = "", hintTag:String = "") {
        
        // Initialize
        self.id = id
        self.pageType = pageType
        self.imageName = imageName
        self.chapter = chapter
        self.title = title
        self.pageNumber = pageNumber
        self.previousPage = previousPage
        self.nextPage = nextPage
        self.showStats = showStats
        self.chapter = (chapter != "") ? chapter : MangaPage.defaultChapter
        self.endGame = endGame
        self.suppressReading = suppressReadings
        self.backgroundMusic = MangaPage.defaultBackgroundMusic
        self.backgroundSound = MangaPage.defaultBackgroundSound
        self.weather = MangaPage.defaultWeather
        self.loadResourceTag = loadResourceTag
        self.releaseResourceTag = releaseResourceTag
        self.prefetchResourceTag = prefetchResourceTag
        self.hasFunctionsMenu = MangaPage.defaultHasFunctionsMenu
        self.hintTag = hintTag
        self.map = (map != "") ? map : MangaPage.defaultMap
        self.blueprints = (blueprint != "") ? blueprint : MangaPage.defaultBlueprint
        self.loadResourceTag = (loadResourceTag != "") ? loadResourceTag : MangaPage.defaultLoadResourceTag
        self.releaseResourceTag = (releaseResourceTag != "") ? releaseResourceTag : MangaPage.defaultReleaseResourceTag
        self.prefetchResourceTag = (prefetchResourceTag != "") ? prefetchResourceTag : MangaPage.defaultPrefetchResourceTag
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.page)
        
        self.id = deserializer.string()
        self.pageType.from(deserializer.int())
        self.imageName = deserializer.string()
        self.weather.from(deserializer.int())
        self.title = deserializer.string()
        self.pageNumber = deserializer.int()
        self.backgroundMusic = deserializer.string()
        self.backgroundSound = deserializer.string()
        self.soundEffect = deserializer.string()
        self.chapter = deserializer.string()
        self.previousPage = deserializer.string()
        self.nextPage = deserializer.string()
        self.loadResourceTag = deserializer.string()
        self.releaseResourceTag = deserializer.string()
        self.prefetchResourceTag = deserializer.string()
        self.zones = deserializer.children(divider: Divider.pageElements)
        self.captions = deserializer.children(divider: Divider.pageElements)
        self.balloons = deserializer.children(divider: Divider.pageElements)
        self.wordArt = deserializer.children(divider: Divider.pageElements)
        self.detailImages = deserializer.children(divider: Divider.pageElements)
        self.navigationPoints = deserializer.children(divider: Divider.pageElements)
        self.interactions = deserializer.children(divider: Divider.pageElements)
        self.panels = deserializer.children(divider: Divider.pageElements)
        self.actions = deserializer.child()
        self.conversationA = deserializer.child()
        self.conversationB = deserializer.child()
        self.pin = deserializer.child()
        self.symbol = deserializer.child()
        self.showStats = deserializer.bool()
        self.endGame = deserializer.bool()
        self.onLoadAction = deserializer.string(isBase64Encoded: true)
        self.suppressReading = deserializer.bool()
        self.hasFunctionsMenu = deserializer.bool()
        self.hintTag = deserializer.string()
        self.hints = deserializer.children(divider: Divider.pageElements)
        self.map = deserializer.string()
        self.blueprints = deserializer.string()
        self.note = deserializer.child()
        self.npc = deserializer.child()
        
        // Finalize
        if let conversationA {
            conversationA.parent = self
        }
        
        if let conversationB {
            conversationB.parent = self
        }
    }
    
    // MARK: - Functions
    /// Creates a new instance of the touch zone with the given parameters.
    /// - Parameters:
    ///   - tag: The tag representing the action to take.
    ///   - x1: The x coordinate of the top left corner.
    ///   - y1: The y coordinate of the top left corner.
    ///   - x2: The x coordinate of the bottom right corner.
    ///   - y2: The y coordinate of the bottom right corner.
    /// - Returns: Returns self.
    @discardableResult public func addZone(tag:String, x1:Int, y1:Int, x2:Int, y2:Int) -> MangaPage {
        
        // Add a new touch zone
        zones.append(MangaPageTouchZone(tag: tag, x1: x1, y1: y1, x2: x2, y2: y2))
        
        return self
    }
    
    /// Adds a new revealable hint to this location.
    /// - Parameters:
    ///   - text: The text of the hint.
    ///   - pointCost: The amount of points that the hint will cost.
    ///   - beforeReveal: The Grace Script to run before revealing this hint.
    ///   - onReveal: The grace script to run when this hint is revealed.
    /// - Returns: Returns self.
    @discardableResult public func addHint(text:String, pointCost:Int = 0, beforeReveal:String = "", onReveal:String = "") -> MangaPage {
        
        // Add new hint
        hints.append(MangaPageHint(id:hints.count, text: text, pointCost: pointCost, beforeReveal: beforeReveal, onReveal: onReveal))
        
        return self
    }
    
    /// Sets whether or not this location shows the functions menu.
    /// - Parameter value: If `true` the functions menu is shown, else it is not.
    /// - Returns: Returns self.
    @discardableResult public func showFunctionMenu(_ value:Bool) -> MangaPage {
        
        hasFunctionsMenu = value
        
        return self
    }
    
    // !!!: Navigation Points
    /// Creates a new navigation point and adds it to the collection.
    /// - Parameters:
    ///   - tag: The tag representing the action to take.
    ///   - layerVisibility: The layer visibility to display the navigation point at.
    ///   - pitch: The camera pitch.
    ///   - yaw: The camera yaw.
    ///   - soundEffect: The sound effect to play when taking this navigation point.
    ///   - condition: A condition in Grace Script that must evaluate to `true` for the navigation point to be active.
    /// - Returns: Returns self.
    @discardableResult public func addNavigationPoint(tag:String, layerVisibility:MangaLayerManager.ElementVisibility = .displayNothing, soundEffect:String = "", pitch:Float = 0.0, yaw:Float = 0.0, condition:String = "") -> MangaPage {
        
        // Add a new navigation point
        navigationPoints.append(MangaPageNavigationPoint(tag: tag, layerVisibility: layerVisibility, soundEffect: soundEffect, pitch: pitch, yaw: yaw, condition: condition))
        
        return self
    }
    
    /// Checks to see if the given rotation key hits a navigation point in this location.
    /// - Parameter layerVisibility: The layer Visibility to check for.
    /// - Returns: Returns the navigation point if found, else returns `nil`.
    public func navigationPointHit(_ layerVisibility:MangaLayerManager.ElementVisibility) -> MangaPageNavigationPoint? {
        
        // Scan all navigation points for key
        for point in navigationPoints {
            if point.layerVisibility == layerVisibility {
                if point.condition == "" {
                    return point
                } else if MangaWorks.evaluateCondition(point.condition) {
                    return point
                }
            }
        }
        
        // Not found
        return nil
    }
    
    /// Checks to see if the current camera rotation hits a navigation point at this location.
    /// - Parameters:
    ///   - pitch: The current camera pitch.
    ///   - yaw: The current camera yaw.
    /// - Returns: Returns the navigation point if found, else returns `nil`.
    public func navigationPointHit(pitch:Float, yaw:Float) -> MangaPageNavigationPoint? {
        
        // Scan all navigation points for key
        for point in navigationPoints {
            if point.layerVisibility == .displayNothing && PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: point.pitchLeading, pitchTrailing: point.pitchTrailing, yawLeading: point.yawLeading, yawTrailing: point.yawTrailing) {
                if point.condition == "" {
                    return point
                } else if MangaWorks.evaluateCondition(point.condition) {
                    return point
                }
            }
        }
        
        // Not found
        return nil
    }
    
    // !!!: Interactions
    /// Creates a new interaction and adds it to the collection.
    /// - Parameters:
    ///   - action: The type of interaction to create.
    ///   - title: The title of the interaction.
    ///   - handler: The action to take when the user activates the interaction.
    ///   - layerVisibility: The layer visibility for this interaction.
    ///   - pitch: The pitch to display the interaction at.
    ///   - yaw: The yaw to display the interaction at.
    ///   - notebookID: The notebook to record the interaction in.
    ///   - notebookTitle: The notebook title to record the interaction in.
    ///   - notebookEntry: The notebook entry to record the interaction in.
    ///   - notebookImage: An optional image that can be attached to a notebook entry.
    ///   - condition: A Grace Language condition that must be met for this interaction to be active.
    ///   - soundEffect: A sound effect to play when the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addInteraction(action:MangaPageInteraction.ActionType, title:String, layerVisibility:MangaLayerManager.ElementVisibility = .displayNothing, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, notebookID:String = "", notebookTitle:String = "", notebookEntry:String = "", notebookImage:String = "", condition:String = "", handler:String = "", soundEffect:String = "") -> MangaPage {
        
        // Add new interaction point
        interactions.append(MangaPageInteraction(action: action, title: title, displayElement: layerVisibility, pitch: pitch, yaw: yaw, notebookID: notebookID, notebookTitle: notebookTitle, notebookEntry: notebookEntry, notebookImage: notebookImage, condition: condition, handler: handler, soundEffect: soundEffect))
        
        return self
    }
    
    /// Creates a new interaction and adds it to the collection.
    /// - Parameters:
    ///   - action: The type of interaction to create
    ///   - title: The title for the interaction
    ///   - pitch: The pitch to display the interaction at.
    ///   - yaw: The yaw to display the interaction at.
    ///   - notebookID: The notebook to store the interaction in.
    ///   - notebookTitle: The notebook title, if one does not already exist.
    ///   - notebookEntry: The note to add to the notebook.
    ///   - notebookImage: An optional image that can be attached to a notebook entry.
    ///   - soundEffect: The sound effect to play when taking this interaction.
    ///   - visibility: The layer object ot make visible when the user activates this interaction.
    ///   - nextMangaPageID: The new location to view.
    ///   - condition: The script that controls in the interaction is visible or not.
    ///   - soundEffect: A sound effect to play when the user takes this action.
    /// - Returns: Returns self.
    @discardableResult public func addInteraction(action:MangaPageInteraction.ActionType, title:String, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, notebookID:String = "", notebookTitle:String = "", notebookEntry:String = "", notebookImage:String = "", soundEffect:String = "", visibility:MangaLayerManager.ElementVisibility = .displayNothing, nextMangaPageID:String = "", points:Int = 0, condition:String = "") -> MangaPage {
        
        // Assemble script
        let script = MangaPage.composeGraceScript(soundEffect: soundEffect, points: points, pageID: nextMangaPageID, visibility: visibility)
        
        // Add new interaction point
        interactions.append(MangaPageInteraction(action: action, title: title, displayElement: visibility, pitch: pitch, yaw: yaw, notebookID: notebookID, notebookTitle: notebookTitle, notebookEntry: notebookEntry, notebookImage: notebookImage, condition: condition, handler: script))
        
        return self
    }
    
    /// Checks to see if the given rotation key hits an interaction in this location.
    /// - Returns: Returns the `MapInteraction` hit or `nil` if no interaction hit.
    /// - Parameters:
    ///   - layerVisibility: The layer visibility to check.
    ///   - pitch: The pitch to test.
    ///   - yaw: The yaw to test.
    public func interactionHit(_ layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> MangaPageInteraction? {
        
        // Scan all interactions for key
        for interaction in interactions {
            if interaction.displayElement == layerVisibility || PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: interaction.pitchLeading, pitchTrailing: interaction.pitchTrailing, yawLeading: interaction.yawLeading, yawTrailing: interaction.yawTrailing){
                if interaction.condition == "" {
                    return interaction
                } else if MangaWorks.evaluateCondition(interaction.condition) {
                    return interaction
                }
            }
        }
        
        // Not found
        return nil
    }
    
    // !!!: Actions
    /// Creates a new action group and attaches it to the location.
    /// - Parameter title: The title for the HUD.
    /// - Returns: The new actions created.
    @discardableResult public func addActions(title:String, maxEntries:Int = 2) -> MangaPageActions {
        let element = MangaPageActions(title: title, maxEntries: maxEntries)
        actions = element
        
        return element
    }
    
    // !!!: Notes
    /// Adds a notebook entry to this page.
    /// - Parameters:
    ///   - notebookID: The unique ID of the notebook entry.
    ///   - image: An optional image for the entry.
    ///   - title: The title of the entry.
    ///   - entry: The body of the entry.
    @discardableResult public func addNote(notebookID: String = "", image: String = "", title: String = "", entry: String = "") -> MangaPage {
        note = MangaNotebookEntry(notebookID: notebookID, image: image, title: title, entry: entry)
        
        return self
    }
    
    // !!!: NPC Conversations
    /// Adds an NPC conversation to this page.
    /// - Parameters:
    ///   - theme: The theme that the NPC should be triggered for. Zero will match any theme.
    ///   - id: The unique ID of the NPC.
    ///   - conversationPage: The address of the page that holds the conversation.
    /// - Returns: self.
    @discardableResult public func addNPC(theme: Int, id: String, conversationPage: String) -> MangaPage {
        npc = MangaPageNPC(theme: theme, id: id, conversationPage: conversationPage)
        
        return self
    }
    
    // !!!: Conversation
    /// Creates a anew conversation and adds it to the location.
    /// - Parameters:
    ///   - portrait: The character's portriat image.
    ///   - name: The characters name.
    ///   - message: The message to dispplay to the user.
    ///   - visibility: Which conversation slot ot add the conversation to.
    ///   - maxEntries: The maximum number of entries to display at one time.
    /// - Returns: The new conversation created.
    @discardableResult public func addConversation(actor:MangaVoiceActors, portrait:String, name:String, message:String, visibility:MangaLayerManager.ElementVisibility, maxEntries:Int = 2) -> MangaPageConversation {
        let conversation = MangaPageConversation(parent: self, actor: actor, portrait: portrait, name: name, message: message, visibility: visibility, maxEntries: maxEntries)
        
        switch visibility {
        case .displayConversationA:
            self.conversationA = conversation
        case .displayConversationB:
            self.conversationB = conversation
        default:
            break
        }
        
        return conversation
    }
    
    // !!!: PIN Number Entry
    /// Creates a new PIN entry form on the current location.
    /// - Parameters:
    ///   - title: The title for the PIN entry.
    ///   - pinValue: The State variable that holds the PIN.
    ///   - failLocation: The location to go to if the PIN entry fails.
    ///   - succeedLocation: The location to go to in the PIN entry is successful.
    /// - Returns: Returns self.
    @discardableResult public func addPin(title:String, pinValue:String = "", failLocation:String = "", succeedLocation:String = "", action:String = "") -> MangaPage {
        
        pin = MangaPagePin(title: title, pinValue: pinValue, failLocation: failLocation, succeedLocation: succeedLocation, action:action)
        
        return self
    }
    
    // !!!: Add Symbol Entry
    /// Creates a new Symbol entry form on the current location.
    /// - Parameters:
    ///   - title: The title foe the Symbol entry.
    ///   - symbolValue: The desired symbol pattern in the form 0000|0000|0000|0000.
    ///   - failLocation: The location to go if the symbol entry fails.
    ///   - succeedLocation: The location to go to if the symbol entry is successful.
    ///   - action: The options action to take when the symbol is entered.
    /// - Returns: Returns self.
    @discardableResult public func addSymbol(title:String, symbolValue:String, failLocation:String = "", succeedLocation:String = "", action:String = "") -> MangaPage {
        
        symbol = MangaPageSymbol(title: title, symbolValue: symbolValue, failLocation: failLocation, succeedLocation: succeedLocation, action:action)
        
        return self
    }
    
    // !!!: Panels
    /// Creates a new panel at the given placement with the given parameters
    /// - Parameters:
    ///   - placement: Where the panel is to be placed on the comic page.
    ///   - title: The title for the panel.
    ///   - imageName: The background image for the panel.
    ///   - imageScale: The scale of the image.
    ///   - imageAnchor: The anchor point for the image.
    ///   - backgroundColor: The background color for the panel.
    ///   - widthScale: The width scaling factor for the panel.
    ///   - heightScale: The height scaling factor for the panel.
    /// - Returns: Returns self.
    @discardableResult public func addPanel(placement:MangaPageElementPlacement, title:String = "", imageName:String = "", imageScale:Float = 1.0, imageAnchor:MangaPagePanel.ImagePlacement = .topLeading, offsetHorizontal:CGFloat = 0.0, offsetVertical:CGFloat = 0.0, backgroundColor:Color = .black, widthScale:Float = 1.0, heightScale:Float = 1.0, condition:String = "") -> MangaPage {
        
        panels[placement.rawValue] = MangaPagePanel(title: title, imageName: imageName, imageWidthScale:imageScale, imageHeightScale: imageScale, imageAnchor: imageAnchor, offsetHorizontal: offsetHorizontal, offsetVertical: offsetVertical, backgroundColor: backgroundColor, widthScale: widthScale, heightScale: heightScale, condition: condition)
        
        return self
    }
    
    /// Returns the panel at the given placement location.
    /// - Parameter placement: Where the panel is to be placed on the comic page.
    /// - Returns: The `MapPanel` at the given location or `nil` if not found.
    public func getPanel(at placement:MangaPageElementPlacement) -> MangaPagePanel? {
        return panels[placement.rawValue]
    }
    
    // !!!: Captions
    /// Creates a new caption at the given placement with the given parameters.
    /// - Parameters:
    ///   - placement: Where the caption is to be placed on the comic page.
    ///   - caption: The body of the caption.
    ///   - fontName: The name of the font to use.
    ///   - fontSize: The font size.
    ///   - fontColor: The font color.
    ///   - backgroundColor: The background color of the caption box.
    ///   - boxWidth: The width of the caption box.
    ///   - visibility: If set, defines when this element is visible.
    /// - Returns: Returns self.
    @discardableResult public func addCaption(placement:MangaPageElementPlacement, actor:MangaVoiceActors = .narrator, caption:String, font:ComicFonts = .KomikaTight, fontSize:Float = 24, fontColor:Color = Color.black, backgroundColor:Color = Color.white, boxWidth:Float = 200.0, xOffset:Float = 0.0, yOffset:Float = 0.0, visibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, animation:MangaAnimation = MangaAnimation(), condition:String = "") -> MangaPage {
        
        // decide which of the key values should be used
        var isVisible = visibility
        
        if pitch != PanoramaManager.emptyPoint || yaw != PanoramaManager.emptyPoint {
            isVisible = .displayNothing
        }
        
        // Add caption to given location
        captions[placement.rawValue] = MangaPageCaption(actor:actor, caption: caption, font: font, fontSize: fontSize, fontColor: fontColor, backgroundColor: backgroundColor, boxWidth: boxWidth, xOffset: xOffset, yOffset: yOffset, layerVisibility: isVisible, pitch: pitch, yaw: yaw, animation: animation, condition: condition)
        
        return self
    }
    
    /// Returns the Caption Layout Pattern for the given key value. This is used to decide if the caption layer needs to be redrawn for the panorama rotation.
    /// - Parameters:
    ///   - layerVisibility: The key to generate the layouts for.
    ///   - pitch: The pitch to generate the layouts for.
    ///   - yaw: The yaw to generate the layouts for.
    /// - Returns: The layout pattern for the given key, pitch and yaw.
    public func getCaptionLayout(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> String {
        var result = ""
        
        for caption in captions {
            var display = "0"
            
            if let caption = caption {
                if caption.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                    if MangaWorks.evaluateCondition(caption.condition) {
                        display = "1"
                    }
                } else if caption.layerVisibility == layerVisibility {
                    display = "1"
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: caption.pitchLeading, pitchTrailing: caption.pitchTrailing, yawLeading: caption.yawLeading, yawTrailing: caption.yawTrailing) {
                    display = "1"
                }
            }
            
            result += display
        }
        
        return result
    }
    
    /// Returns the Caption for the given location and rotation key.
    /// - Parameters:
    ///   - placement: The location of the Caption.
    ///   - layerVisibility: The rotation key.
    ///   - pitch: The rotation pitch.
    ///   - yaw: The rotation yaw.
    /// - Returns: The requested Caption or `nil`.
    public func getCaption(at placement:MangaPageElementPlacement, for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> MangaPageCaption? {
        
        let index = placement.rawValue
        
        guard index >= 0 && index < captions.count else {
            return nil
        }
        
        guard let caption = captions[index] else {
            return nil
        }
        
        if caption.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
            if MangaWorks.evaluateCondition(caption.condition) {
                return caption
            }
        } else if caption.layerVisibility == layerVisibility {
            if MangaWorks.evaluateCondition(caption.condition) {
                return caption
            }
        } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: caption.pitchLeading, pitchTrailing: caption.pitchTrailing, yawLeading: caption.yawLeading, yawTrailing: caption.yawTrailing) {
            if MangaWorks.evaluateCondition(caption.condition) {
                return caption
            }
        }
        
        return nil
    }
    
    // !!!: Balloons
    /// Creates a new balloon at the given placement with the given parameters.
    /// - Parameters:
    ///   - placement: Where the ballon is to be placed on the comic page.
    ///   - caption: The body of the caption.
    ///   - type: The type of balloon to create.
    ///   - fontName: The name of the font to use.
    ///   - fontSize: The font size.
    ///   - fontColor: The font color.
    ///   - boxWidth: The width of the caption box.
    ///   - key: A rotation key indicating when this caption should be displayed. The default is the always display the caption.
    ///   - visibility: The key needed to make this element visible.
    /// - Returns: Returns self.
    @discardableResult public func addBalloon(placement:MangaPageElementPlacement, actor:MangaVoiceActors, caption:String, type:MangaPageSpeechBalloon.BalloonType = .talk, tail:MangaPageSpeechBalloon.TailOrientation = .bottomTrailing, font:ComicFonts = .KomikaTight, fontSize:Float = 24, fontColor:Color = Color.black, boxWidth:Float = 200.0, xOffset:Float = 0.0, yOffset:Float = 0.0, visibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, animation:MangaAnimation = MangaAnimation(), condition:String = "") -> MangaPage {
        
        // decide which of the key values should be used
        var isVisible = visibility
        
        if pitch != PanoramaManager.emptyPoint || yaw != PanoramaManager.emptyPoint {
            isVisible = .displayNothing
        }
        
        // Add caption to given location
        balloons[placement.rawValue] = MangaPageSpeechBalloon(actor:actor, caption: caption, type:type, tail:tail, font: font, fontSize: fontSize, fontColor: fontColor, boxWidth: boxWidth, xOffset: xOffset, yOffset: yOffset, layerVisibility: isVisible, pitch: pitch, yaw: yaw, animation: animation, condition: condition)
        
        return self
    }
    
    /// Returns the Balloon Layout Pattern for the given key value. This is used to decide if the caption layer needs to be redrawn for the panorama rotation.
    /// - Parameters:
    ///   - layerVisibility: The key to generate the layouts for.
    ///   - pitch: The pitch to generate the layouts for.
    ///   - yaw: The yaw to generate the layouts for.
    /// - Returns: The layout pattern for the given key, pitch and yaw.
    public func getBalloonLayout(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> String {
        var result = ""
        
        for balloon in balloons {
            var display = "0"
            
            if let balloon = balloon {
                if balloon.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                    if MangaWorks.evaluateCondition(balloon.condition) {
                        display = "1"
                    }
                } else if balloon.layerVisibility == layerVisibility {
                    display = "1"
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: balloon.pitchLeading, pitchTrailing: balloon.pitchTrailing, yawLeading: balloon.yawLeading, yawTrailing: balloon.yawTrailing) {
                    display = "1"
                }
            }
            
            result += display
        }
        
        return result
    }
    
    /// Returns the Balloon for the given location and rotation key.
    /// - Parameters:
    ///   - placement: The location of the Balloon.
    ///   - layerVisibility: The rotation key.
    /// - Returns: The requested Balloon or `nil`
    public func getBalloon(at placement:MangaPageElementPlacement, for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> MangaPageSpeechBalloon? {
        
        let index = placement.rawValue
        
        guard index >= 0 && index < balloons.count else {
            return nil
        }
        
        guard let balloon = balloons[index] else {
            return nil
        }
        
        if balloon.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
            if MangaWorks.evaluateCondition(balloon.condition) {
                return balloon
            }
        } else if balloon.layerVisibility == layerVisibility {
            if MangaWorks.evaluateCondition(balloon.condition) {
                return balloon
            }
        } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: balloon.pitchLeading, pitchTrailing: balloon.pitchTrailing, yawLeading: balloon.yawLeading, yawTrailing: balloon.yawTrailing) {
            if MangaWorks.evaluateCondition(balloon.condition) {
                return balloon
            }
        }
        
        return nil
    }
    
    // !!!: Page Transcript
    /// Creates a list of all of the text that is visible in the given location based on key, pitch and yaw.
    /// - Parameters:
    ///   - layerVisibility: The key to show text for.
    ///   - pitch: The pitch to show text for.
    ///   - yaw: The yaw to show text for.
    /// - Returns: Returns a list of visible text at the current location or and empty list if no text is visible.
    public func transcript(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> [String] {
        var transcript:[String] = []
        let captionLayout = getCaptionLayout(for:layerVisibility, pitch: pitch, yaw: yaw)
        let balloonLayout = getBalloonLayout(for:layerVisibility, pitch: pitch, yaw: yaw)
        
        // Build transcript from top to bottom
        for n in 0...11 {
            if captionLayout[n] == "1" {
                if let caption = captions[n] {
                    let text = MangaWorks.expandMacros(in: caption.caption)
                    transcript.append("**CAPTION**: \(text)")
                }
            }
            
            if balloonLayout[n] == "1" {
                if let balloon = balloons[n] {
                    let type = balloon.type.rawValue.replacingOccurrences(of: "Balloon", with: "").uppercased()
                    let text = MangaWorks.expandMacros(in: balloon.caption)
                    transcript.append("**\(type)**: \(text)")
                }
            }
        }
        
        return transcript
    }
    
    /// Reads all of the captions and ballons from a page out loud.
    /// - Parameter allText: If `true` all text on the page is read aloud, if `false`, only text that
    public func readText(invisibleText:Bool = true) {
        
        // Should this page be read?
        guard !suppressReading else {
            return
        }
        
        if invisibleText {
            // Read all text on the page.
            for n in 0...11 {
                if let caption = captions[n] {
                    let text = MangaWorks.expandMacros(in: caption.caption)
                    MangaPage.sayPhrase(text, inVoice: caption.actor)
                }
                
                if let balloon = balloons[n] {
                    let text = MangaWorks.expandMacros(in: balloon.caption)
                    MangaPage.sayPhrase(text, inVoice: balloon.actor)
                }
            }
        } else {
            // Read only text that is currently visible on the page.
            for n in 0...11 {
                if let caption = captions[n] {
                    if caption.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                        if MangaWorks.evaluateCondition(caption.condition) {
                            let text = MangaWorks.expandMacros(in: caption.caption)
                            MangaPage.sayPhrase(text, inVoice: caption.actor)
                        }
                    }
                }
                
                if let balloon = balloons[n] {
                    if balloon.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                        if MangaWorks.evaluateCondition(balloon.condition) {
                            let text = MangaWorks.expandMacros(in: balloon.caption)
                            MangaPage.sayPhrase(text, inVoice: balloon.actor)
                        }
                    }
                }
            }
        }
    }
    
    /// Reads any caption or balloon text that was made visible by a user's interaction.
    /// - Parameters:
    ///   - layerVisibility: The rotation key.
    ///   - pitch: The rotation pitch.
    ///   - yaw: The rotation yaw.
    public func readText(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) {
        
        // Should this page be read?
        guard !suppressReading else {
            return
        }
        
        // Read only text that has been made visible by user interaction.
        for n in 0...11 {
            if let caption = captions[n] {
                if caption.layerVisibility == layerVisibility {
                    let text = MangaWorks.expandMacros(in: caption.caption)
                    MangaPage.sayPhrase(text, inVoice: caption.actor)
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: caption.pitchLeading, pitchTrailing: caption.pitchTrailing, yawLeading: caption.yawLeading, yawTrailing: caption.yawTrailing) {
                    let text = MangaWorks.expandMacros(in: caption.caption)
                    MangaPage.sayPhrase(text, inVoice: caption.actor)
                }
            }
            
            if let balloon = balloons[n] {
                if balloon.layerVisibility == layerVisibility {
                    let text = MangaWorks.expandMacros(in: balloon.caption)
                    MangaPage.sayPhrase(text, inVoice: balloon.actor)
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: balloon.pitchLeading, pitchTrailing: balloon.pitchTrailing, yawLeading: balloon.yawLeading, yawTrailing: balloon.yawTrailing) {
                    let text = MangaWorks.expandMacros(in: balloon.caption)
                    MangaPage.sayPhrase(text, inVoice: balloon.actor)
                }
            }
        }
    }
    
    /// When the user rotates a panorama view, read any new text that popups up because of the rotation change.
    /// - Parameters:
    ///   - key: The rotation key.
    ///   - pitch: The rotation pitch.
    ///   - yaw: The rotation yaw.
    public func readNewText(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) {
        
        // Should this page be read?
        guard !suppressReading else {
            return
        }
        
        let newCaptionLayout = getCaptionLayout(for: layerVisibility, pitch: pitch, yaw: yaw)
        if newCaptionLayout != lastReadCaptions {
            for caption in captions {
                if let caption {
                    if caption.layerVisibility == layerVisibility {
                        let text = MangaWorks.expandMacros(in: caption.caption)
                        MangaPage.sayPhrase(text, inVoice: caption.actor)
                    } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: caption.pitchLeading, pitchTrailing: caption.pitchTrailing, yawLeading: caption.yawLeading, yawTrailing: caption.yawTrailing) {
                        let text = MangaWorks.expandMacros(in: caption.caption)
                        MangaPage.sayPhrase(text, inVoice: caption.actor)
                    }
                }
            }
            lastReadCaptions = newCaptionLayout
        }
        
        let newBalloonLayout = getBalloonLayout(for: layerVisibility, pitch: pitch, yaw: yaw)
        if newBalloonLayout == lastReadBallons {
            for balloon in balloons {
                if let balloon {
                    if balloon.layerVisibility == layerVisibility {
                        let text = MangaWorks.expandMacros(in: balloon.caption)
                        MangaPage.sayPhrase(text, inVoice: balloon.actor)
                    } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: balloon.pitchLeading, pitchTrailing: balloon.pitchTrailing, yawLeading: balloon.yawLeading, yawTrailing: balloon.yawTrailing) {
                        let text = MangaWorks.expandMacros(in: balloon.caption)
                        MangaPage.sayPhrase(text, inVoice: balloon.actor)
                    }
                }
            }
            lastReadBallons = newBalloonLayout
        }
    }
    
    // !!!: Word Art
    /// Creates new word art at the given placement with the given parameters.
    /// - Parameters:
    ///   - placement: Where the word art is to be placed on the comic page.
    ///   - title: The title of the word art.
    ///   - fontName: The font name.
    ///   - fontSize: The font size.
    ///   - gradientColors: The color that make of the graident to fill the word art.
    ///   - rotationDegrees: The angle to rotate the word art too.
    ///   - shadowed: If `true`, display and shadow under the word art.
    ///   - key: A rotation key indicating when this caption should be displayed. The default is the always display the caption.
    ///   - visibility: The key needed to make this element visible.
    /// - Returns: Returns self.
    @discardableResult public func addWordArt(placement:MangaPageElementPlacement, title:String, font:ComicFonts = .TrueCrimes, fontSize:Float = 128, gradientColors:[Color] = [.purple, .green], rotationDegrees:Double = 0, shadowed:Bool = true, xOffset:Float = 0.0, yOffset:Float = 0.0, visibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, animation:MangaAnimation = MangaAnimation(), condition:String = "") -> MangaPage {
        
        // decide which of the key values should be used
        var isVisible = visibility
        
        if pitch != PanoramaManager.emptyPoint || yaw != PanoramaManager.emptyPoint {
            isVisible = .displayNothing
        }
        
        // Add Word Art to given location
        wordArt[placement.rawValue] = MangaPageWordArt(title: title, font: font, fontSize: fontSize, gradientColors: gradientColors, rotationDegrees: rotationDegrees, shadowed: shadowed, xOffset: xOffset, yOffset: yOffset, layerVisibility: isVisible, pitch: pitch, yaw: yaw, animation: animation, condition: condition)
        
        return self
    }
    
    /// Returns the Word Art Layout Pattern for the given key value. This is used to decide if the caption layer needs to be redrawn for the panorama rotation.
    /// - Returns: A string representing the caption layout for the given roation key.
    public func getWordArtLayout(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> String {
        var result = ""
        
        for word in wordArt {
            var display = "0"
            
            if let word = word {
                if word.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                    if MangaWorks.evaluateCondition(word.condition) {
                        display = "1"
                    }
                } else if word.layerVisibility == layerVisibility {
                    display = "1"
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: word.pitchLeading, pitchTrailing: word.pitchTrailing, yawLeading: word.yawLeading, yawTrailing: word.yawTrailing) {
                    display = "1"
                }
            }
            
            result += display
        }
        
        return result
    }
    
    /// Returns the Word Art for the given location and rotation key.
    /// - Parameters:
    ///   - placement: The location of the Word Art.
    ///   - key: The rotation key.
    /// - Returns: The requested Word Art or `nil`
    public func getWordArt(at placement:MangaPageElementPlacement, for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> MangaPageWordArt? {
        
        let index = placement.rawValue
        
        guard index >= 0 && index < wordArt.count else {
            return nil
        }
        
        guard let word = wordArt[index] else {
            return nil
        }
        
        if word.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
            if MangaWorks.evaluateCondition(word.condition) {
                return word
            }
        } else if word.layerVisibility == layerVisibility {
            if MangaWorks.evaluateCondition(word.condition) {
                return word
            }
        } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: word.pitchLeading, pitchTrailing: word.pitchTrailing, yawLeading: word.yawLeading, yawTrailing: word.yawTrailing) {
            if MangaWorks.evaluateCondition(word.condition) {
                return word
            }
        }
        
        return nil
    }
    
    // !!!: Detail Images
    /// Creates a new detailed image at the given placement with the given parameters.
    /// - Parameters:
    ///   - placement: Where the detail image is to be placed on the comic page.
    ///   - imageName: The name of the image to display.
    ///   - width: The width of the image box.
    ///   - height: The height of the image box.
    ///   - scale: The scale of the image.
    ///   - shadowed: If `true`, display and shadow under the box.
    ///   - key: A rotation key indicating when this caption should be displayed. The default is the always display the caption.
    ///   - visibility: The key needed to display this element.
    /// - Returns: Returns self.
    @discardableResult public func addDetailImage(placement:MangaPageElementPlacement, imageName:String, width:Float = 400.0, height:Float = 200.0, scale:Float = 0.20, scaleDimentions:Bool = false, hasBackground:Bool = true, backgroundColor:Color = .black, shadowed:Bool = false, xOffset:Float = 0.0, yOffset:Float = 0.0, visibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = PanoramaManager.emptyPoint, yaw:Float = PanoramaManager.emptyPoint, animation:MangaAnimation = MangaAnimation(), condition:String = "") -> MangaPage {
        
        // decide which of the key values should be used
        var isVisible = visibility
        
        if pitch != PanoramaManager.emptyPoint || yaw != PanoramaManager.emptyPoint {
            isVisible = .displayNothing
        }
        
        // Scale dimentions too?
        var adjustedWidth:Float = width
        var adjustedHeight:Float = height
        
        if scaleDimentions {
            adjustedWidth = width * scale
            adjustedHeight = adjustedHeight * scale
        }
       
        // Add Detail Image to the given location
        detailImages[placement.rawValue] = MangaPageDetailImage(imageName: imageName, width: adjustedWidth, height: adjustedHeight, scale: scale, hasBackground: hasBackground, backgroundColor: backgroundColor, shadowed: shadowed, xOffset:xOffset, yOffset: yOffset, layerVisibility: isVisible, pitch: pitch, yaw: yaw, animation: animation, condition: condition)
        
        return self
    }
    
    /// Returns the Detail Image Layout Pattern for the given key value. This is used to decide if the caption layer needs to be redrawn for the panorama rotation.
    /// - Parameter key: The panorama rotation key.
    /// - Returns: A string representing the caption layout for the given roation key.
    public func getDetailImageLayout(for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> String {
        var result = ""
        
        for image in detailImages {
            var display = "0"
            
            if let image = image {
                if image.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
                    if MangaWorks.evaluateCondition(image.condition) {
                        display = "1"
                    }
                } else if image.layerVisibility == layerVisibility {
                    display = "1"
                } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: image.pitchLeading, pitchTrailing: image.pitchTrailing, yawLeading: image.yawLeading, yawTrailing: image.yawTrailing) {
                    display = "1"
                }
            }
            
            result += display
        }
        
        return result
    }
    
    /// Returns the Detail Image for the given location and rotation key.
    /// - Parameters:
    ///   - placement: The location of the Detail Image.
    ///   - key: The rotation key.
    /// - Returns: The requested Detail Image or `nil`
    public func getDetailImage(at placement:MangaPageElementPlacement, for layerVisibility:MangaLayerManager.ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0) -> MangaPageDetailImage? {
        
        let index = placement.rawValue
        
        guard index >= 0 && index < detailImages.count else {
            return nil
        }
        
        guard let image = detailImages[index] else {
            return nil
        }
        
        if image.layerVisibility == MangaLayerManager.ElementVisibility.displayAlways {
            if MangaWorks.evaluateCondition(image.condition) {
                return image
            }
        } else if image.layerVisibility == layerVisibility {
            if MangaWorks.evaluateCondition(image.condition) {
                return image
            }
        } else if PanoramaManager.targetHit(pitch: pitch, yaw: yaw, pitchLeading: image.pitchLeading, pitchTrailing: image.pitchTrailing, yawLeading: image.yawLeading, yawTrailing: image.yawTrailing) {
            if MangaWorks.evaluateCondition(image.condition) {
                return image
            }
        }
        
        return nil
    }
    
    // !!!: Weather
    /// Adds the given weather effect to this location.
    /// - Parameter weather: The type of weather desired at this location.
    /// - Returns: Returns self.
    @discardableResult public func addWeather(weather:WeatherSystem) -> MangaPage {
        
        // Set weather
        self.weather = weather
        
        return self
    }
    
    // !!!: Page Chapter
    /// Adds the given level to this location.
    /// - Parameter level: The level for this location.
    /// - Returns: Returns self.
    @discardableResult public func addChapter(chapter:String) -> MangaPage {
        
        // Set level
        self.chapter = chapter
        
        return self
    }
    
    // !!!: Music and Sound Effects
    /// Adds the given background music to this location.
    /// - Parameter name: The name of the music to add.
    /// - Returns: Returns self.
    @discardableResult public func addBackgroundMusic(name:String) -> MangaPage {
        
        // Set the background music
        backgroundMusic = name
        
        return self
    }
    
    /// Adds the given background sound to this location.
    /// - Parameter name: The name of the sound to add.
    /// - Returns: Returns self.
    @discardableResult public func addBackgroundSound(name:String) -> MangaPage {
        
        // Set the background music
        backgroundSound = name
        
        return self
    }
    
    /// Adds the given sound effect to this location
    /// - Parameter name: The name of the sound effect.
    /// - Returns: Returns self.
    @discardableResult public func addSoundEffect(name:String) -> MangaPage {
        
        // Set the background music
        soundEffect = name
        
        return self
    }
    
    /// Plays any music, sound and/or sound effect attached to this location.
    public func startLocationSounds() {
        // Background music
        switch backgroundMusic {
        case "":
            SoundManager.shared.stopBackgroundMusic()
        case "<continue>":
            // Continue playing the current sound
            break
        default:
            SoundManager.shared.startBackgroundMusic(song: backgroundMusic)
        }
        
        // ßackground sounds
        switch backgroundSound {
        case "":
            SoundManager.shared.stopBackgroundSound()
        case "<continue>":
            // Continue playing the current sound
            break
        default:
            SoundManager.shared.playBackgroundSound(sound: backgroundSound)
        }
        
        // Background Weather
        if hasRainSounds {
            let path = MangaWorks.pathTo(resource: "RainThunder", ofType: "mp3")
            SoundManager.shared.playBackgroundWeather(path: path)
        } else if hasLightningSound {
            let path = MangaWorks.pathTo(resource: "Lightning", ofType: "mp3")
            SoundManager.shared.playBackgroundWeather(path: path)
        } else {
            SoundManager.shared.stopBackgroundWeather()
        }
        
        // Sound effect
        if soundEffect == "" {
            SoundManager.shared.stopSoundEffect(channel: .channel02)
        } else {
            SoundManager.shared.playSoundEffect(sound: soundEffect, channel: .channel02)
        }
        
        // Inform location that it has loaded
        locationLoaded()
    }
    
    // !!!: Location loading event
    /// Defines an action to take whenever the given location is loaded into a game UI.
    /// - Parameter action: A Grace Language script hold the action to take when the page loads.
    /// - Returns: Returns self.
    @discardableResult public func onLoad(_ script:String) -> MangaPage {
        onLoadAction = script
        
        return self
    }
    
    /// Inform a location that it has been loaded in the game UI.
    private func locationLoaded() {
        
        guard onLoadAction != "" else {
            return
        }
        
        Execute.onMain {
            do {
                try GraceRuntime.shared.run(script: self.onLoadAction)
            } catch {
                Log.error(subsystem: "MangaWorks", category: "MangaPage Load", "Error: \(error)")
            }
        }
    }
}
