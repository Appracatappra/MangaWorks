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

/// Hold information about an interactive touch zone on a comic page that forms a virtual button.
open class MangaPageTouchZone {
    
    // MARK: - Properties
    /// A tag representing the action taken when this button is tapped.
    public var tag:String
    
    /// The top left corner of the touch zone.
    public var topCorner:CGPoint
    
    /// The bottom right corner of the touch zone.
    public var bottomCorner:CGPoint
    
    // MARK: - Initializers
    /// Creates a new instance of the touch zone with the given parameters.
    /// - Parameters:
    ///   - tag: The tag representing the action to take.
    ///   - x1: The x coordinate of the top left corner.
    ///   - y1: The y coordinate of the top left corner.
    ///   - x2: The x coordinate of the bottom right corner.
    ///   - y2: The y coordinate of the bottom right corner.
    public init(tag:String, x1:Int, y1:Int, x2:Int, y2:Int) {
        // Initialize
        self.tag = tag
        self.topCorner = CGPoint(x: x1, y: y1)
        self.bottomCorner = CGPoint(x: x2, y: y2)
    }
    
    // MARK: - Functions
    /// Tests a given point to see if it is inside of the his touch zone.
    /// - Parameter location: The location to test.
    /// - Returns: Returns `true` if the point is inside, else returns `false`.
    public func isHit(_ location:CGPoint) -> Bool {
        return (location.x >= topCorner.x && location.x <= bottomCorner.x) && (location.y >= topCorner.y && location.y <= bottomCorner.y)
    }
}
