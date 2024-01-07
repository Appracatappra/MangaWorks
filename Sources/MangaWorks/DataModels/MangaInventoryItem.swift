//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/7/24.
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

/// Holds information about a item that the user can pickup and use in a Manga based game.
@Observable open class MangaInventoryItem: Identifiable, SimpleSerializeable {
    
    // MARK: - Static Properties
    /// If `true` only encode the current state of the inventory item and not its full details.
    public static var serializeStateOnly = true
    
    // MARK: - Enumerations
    /// Defines the status of a given inventory item
    public enum ItemStatus:Int {
        /// The item has not been assigned to any location of interaction spot.
        case unAssigned = 0
        
        /// The player is currently carrying the item in their inventory.
        case inPlayerInventory
        
        /// The item has been hidden on a given `MangaPage`.
        case hiddenOnMangaPage
        
        /// The item has been dropped on a given `MangaPage`.
        case droppedOnMangaPage
        
        // MARK: - Functions
        /// Gets the value from an `unAssigned` and defaults to `topLeading` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = ItemStatus(rawValue: value) {
                self = enumeration
            } else {
                self = .unAssigned
            }
        }
    }
    
    // MARK: - Properties
    /// The source for the items images.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The unique ID of the inventory item.
    public var id:String = ""
    
    /// The status of the inventory item.
    public var status:ItemStatus = .unAssigned
    
    /// The ID of the `MangaPage` that the item has been hidden or dropped on.
    public var mangaPageID:String = ""
    
    /// The image of the item to display in the game's UI.
    public var image:String = ""
    
    /// The title of the item.
    public var title:String = ""
    
    /// The full description of the item.
    public var description:String = ""
    
    /// If `true`, the item is consumable and can be used up during game play.
    public var isConsumable:Bool = false
    
    /// The initial quantity of a consumable item.
    public var initialQualtity:Int = 1
    
    /// The remaining quantity of a consumable item.
    public var quantityRemaining:Int = 1
    
    /// A Grace Langauge Script to run when the player acquires the item.
    public var onAquire:String = ""
    
    /// A Grace Language Script to run if the player loses the item.
    public var onLost:String = ""
    
    /// A Grace Language Script to run if the player uses the item.
    public var onUse:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.item)
            .append(id)
            .append(status)
            .append(mangaPageID)
            .append(quantityRemaining)
        
        if !MangaInventoryItem.serializeStateOnly {
            serializer.append(imageSource)
                .append(image)
                .append(title)
                .append(description)
                .append(isConsumable)
                .append(initialQualtity)
                .append(onAquire, isBase64Encoded: true)
                .append(onLost, isBase64Encoded: true)
                .append(onUse, isBase64Encoded: true)
        }
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: The source for the items images.
    ///   - id: The unique ID of the inventory item.
    ///   - status: The status of the inventory item.
    ///   - mangaPageID: The ID of the `MangaPage` that the item has been hidden or dropped on.
    ///   - image: The image of the item to display in the game's UI.
    ///   - title: The title of the item.
    ///   - description: The full description of the item.
    ///   - isConsumable: If `true`, the item is consumable and can be used up during game play.
    ///   - initialQualtity: The initial quantity of a consumable item.
    ///   - quantityRemaining: The remaining quantity of a consumable item.
    ///   - onAquire: A Grace Langauge Script to run when the player acquires the item.
    ///   - onLost: A Grace Language Script to run if the player loses the item.
    ///   - onUse: A Grace Language Script to run if the player uses the item.
    public init(imageSource: MangaWorks.Source = .appBundle, id: String = "", status: ItemStatus = .unAssigned, mangaPageID: String = "", image: String = "", title: String = "", description: String = "", isConsumable: Bool = false, initialQualtity: Int = 1, quantityRemaining: Int = 1, onAquire: String = "", onLost: String = "", onUse: String = "") {
        self.imageSource = imageSource
        self.id = id
        self.status = status
        self.mangaPageID = mangaPageID
        self.image = image
        self.title = title
        self.description = description
        self.isConsumable = isConsumable
        self.initialQualtity = initialQualtity
        self.quantityRemaining = quantityRemaining
        self.onAquire = onAquire
        self.onLost = onLost
        self.onUse = onUse
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.item)
        
        self.id = deserializer.string()
        self.status.from(deserializer.int())
        self.mangaPageID = deserializer.string()
        self.quantityRemaining = deserializer.int()
        
        if !MangaInventoryItem.serializeStateOnly {
            self.imageSource.from(deserializer.int())
            self.image = deserializer.string()
            self.title = deserializer.string()
            self.description = deserializer.string()
            self.isConsumable = deserializer.bool()
            self.initialQualtity = deserializer.int()
            self.onAquire = deserializer.string(isBase64Encoded: true)
            self.onLost = deserializer.string(isBase64Encoded: true)
            self.onUse = deserializer.string(isBase64Encoded: true)
        }
    }
}
