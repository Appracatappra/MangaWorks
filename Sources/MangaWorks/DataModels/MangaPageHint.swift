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

/// Holds information about a hint that can be attached to a manga page.
@Observable open class MangaPageHint: Identifiable {
    
    // MARK: - Properties
    /// The unique ID of the hint.
    public var id:Int = 0
    
    /// The text of the hint.
    public var text:String = ""
    
    /// The point cost for the hint.
    public var pointCost:Int = 0
    
    /// The credit cost for the hint.
    public var creditCost:Int = 0
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The unique ID of the hint.
    ///   - text: The text of the hint.
    ///   - pointCost: The point cost for the hint.
    ///   - creditCost: The credit cost for the hint.
    public init(id:Int, text:String = "", pointCost:Int = 0, creditCost:Int = 0) {
        self.id = id
        self.text = text
        self.pointCost = pointCost
        self.creditCost = creditCost
    }
}
