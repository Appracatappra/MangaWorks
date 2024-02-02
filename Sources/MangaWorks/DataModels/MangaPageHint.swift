//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SwiftUIPanoramaViewer
import SimpleSerializer

/// Holds information about a hint that can be attached to a manga page.
@Observable open class MangaPageHint: Identifiable, SimpleSerializeable {
    
    // MARK: - Properties
    /// The unique ID of the hint.
    public var id:Int = 0
    
    /// The text of the hint.
    public var text:String = ""
    
    /// The point cost for the hint.
    public var pointCost:Int = 0
    
    /// The Grace Script to run before revealing this hint.
    public var beforeReveal:String = ""
    
    /// The grace script to run when this hint is revealed.
    public var onReveal:String = ""
    
    // MARK: - Computed Properties
    /// Returns the object as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.hint)
            .append(id)
            .append(text)
            .append(pointCost)
            .append(beforeReveal, isBase64Encoded: true)
            .append(onReveal, isBase64Encoded: true)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The unique ID of the hint.
    ///   - text: The text of the hint.
    ///   - pointCost: The point cost for the hint.
    ///   - beforeReveal: The Grace Script to run before revealing this hint.
    ///   - onReveal: The grace script to run when this hint is revealed.
    public init(id:Int, text:String = "", pointCost:Int = 0, beforeReveal:String = "", onReveal:String = "") {
        self.id = id
        self.text = text
        self.pointCost = pointCost
        self.beforeReveal = beforeReveal
        self.onReveal = onReveal
    }
    
    /// Creates a new instance.
    /// - Parameter value: A serialized string representing the object.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.hint)
        
        self.id = deserializer.int()
        self.text = deserializer.string()
        self.pointCost = deserializer.int()
        self.beforeReveal = deserializer.string(isBase64Encoded: true)
        self.onReveal = deserializer.string(isBase64Encoded: true)
    }
}
