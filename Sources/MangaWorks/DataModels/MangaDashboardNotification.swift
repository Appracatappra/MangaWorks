//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/2/24.
//

import Foundation

/// Class to hold a notification to show on the simulated iPhone that is on the landscape view.
@Observable open class MangaDashboardNotification {
    
    // MARK: - Properties
    /// The icon to display for the notification.
    public var icon:String = "note.text"
    
    /// The title to display for the notification.
    public var title:String = ""
    
    /// The description to display for the notification.
    public var description:String = ""
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - icon: The icon to display for the notification.
    ///   - title: The title to display for the notification.
    ///   - description: The description to display for the notification.
    public init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}
