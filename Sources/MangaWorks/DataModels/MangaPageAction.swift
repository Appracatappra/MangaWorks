//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation

/// Class to hold an action that a user can take on a Manga Page.
@Observable open class MangaPageAction: Identifiable {
    
    // MARK: - Properties
    /// The unique ID of the action.
    public var id:Int = 0
    
    /// The text description of the action.
    public var text:String = ""
    
    /// A condition that must evaluate to `true` written as a Grace Language macro.
    public var condition:String = ""
    
    /// The Grace Language script to run when the user takes this action.
    public var excute:String = ""
    
    // MARK: - Computed Properties
    /// Returns a `MangaActionView` for this action.
    public var view:MangaActionView {
        return MangaActionView(text: text, action: excute)
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - id: The unique ID of the action.
    ///   - text: The text description of the action.
    ///   - condition: A condition that must evaluate to `true` written as a Grace Language macro.
    ///   - excute: The Grace Language script to run when the user takes this action.
    public init(id:Int, text:String, condition:String = "", excute:String = "") {
        // Initialize
        self.id = id
        self.text = text
        self.excute = excute
        self.condition = condition
    }
}
