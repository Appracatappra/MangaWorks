//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation

/// Holds a pin number that can be entered by the player to unlock a feature of a manga page.
@Observable open class MangaPagePin {
    
    // MARK: - Properties
    /// The title to display in the PIN editor.
    public var title:String = ""
    
    /// The PIN value that the user needs to enter.
    public var pinValue:String = ""
    
    /// The ID of the manga page to display in the user enters the PIN incorrectly.
    public var failMangaPageID:String = ""
    
    /// The ID of the manga page to display in the user enters the PIN correctly.
    public var succeedMangaPageID:String = ""
    
    /// The Grace Langauage script to run if the user enters the pin correctly.
    public var action:String = ""
    
    // MARK: - Initializers
    /// Creates a new  instance.
    /// - Parameters:
    ///   - title: The title to display in the PIN editor.
    ///   - pinValue: The PIN value that the user needs to enter.
    ///   - failLocation: The ID of the manga page to display in the user enters the PIN incorrectly.
    ///   - succeedLocation: The ID of the manga page to display in the user enters the PIN correctly.
    ///   - action: The Grace Langauage script to run if the user enters the pin correctly.
    public init(title:String, pinValue:String = "", failLocation:String = "", succeedLocation:String = "", action:String = "") {
        // Initialize
        self.title = title
        self.pinValue = pinValue
        self.failMangaPageID = failLocation
        self.succeedMangaPageID = succeedLocation
        self.action = action
    }
}
