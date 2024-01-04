//
//  MapAnimation.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 4/12/22.
//

import Foundation
import SwiftUI
import Observation
import SimpleSerializer

// TODO: Cannot remove `ObservableObject` from this class.
/// Class that holds the definition and handling of animations for layer objects (Captions, Balloons, Word Art and Detail Images).
@Observable open class MangaAnimation: ObservableObject, SimpleSerializeable {
    
    // MARK: - Properties
    /// If `true` the current item needs to be animated when displayed.
    public var isAnimated:Bool = false
    
    /// The time in seconds before the animation starts.
    public var delay:Double = 0.5
    
    /// The starting object opacity.
    public var opacityStart:Double = 1.0
    
    /// The ending object opacity.
    public var opacityEnd:Double = 1.0
    
    /// The starting X Offset.
    public var xOffsetStart:CGFloat = 0.0
    
    /// The starting Y Offset.
    public var yOffsetStart:CGFloat = 0.0
    
    /// The ending X Offset.
    public var xOffsetEnd:CGFloat = 0.0
    
    /// The ending Y Offset
    public var yOffsetEnd:CGFloat = 0.0
    
    /// The starting rotation degrees.
    public var rotationDegreesStart:Double = 0.0
    
    /// The ending rotation degrees.
    public var rotationDegreesEnd:Double = 0.0
    
    /// If `true` the animation will repeat forever.
    public var repeats:Bool = false
    
    /// If `repeats` is `true` this is the number of times the animation repeats. If set to zero (0), the animation will repeat forever.
    public var cycles:Int = 0
    
    /// If `true` and `repeats` is `true`, the animation will ping-pong between the starting and ending values.
    public var autoReverse:Bool = true
    
    /// The amount of time in seconds that it takes to complete the animation.
    public var duration:Double = 1.0
    
    // MARK: - State Properties
    /// Holds the current opacity value during the animation.
    public var currentOpacity:Double = 1.0
    
    /// The current X Offset during animation.
    public var currentOffsetX:CGFloat = 0.0
    
    /// The current Y Offset during animation.
    public var currentOffsetY:CGFloat = 0.0
    
    /// The current rotation degrees during the animation
    public var currentRotationDegrees:Double = 0.0
    
    // MARK: - Computed Properties
    /// The `MangaAnimation` as a serialized string.
    public var serialized: String {
        let serializer = Serializer(divider: Divider.animation)
            .append(isAnimated)
            .append(delay)
            .append(opacityStart)
            .append(opacityEnd)
            .append(xOffsetStart)
            .append(xOffsetEnd)
            .append(yOffsetStart)
            .append(yOffsetEnd)
            .append(rotationDegreesStart)
            .append(rotationDegreesEnd)
            .append(repeats)
            .append(cycles)
            .append(autoReverse)
            .append(duration)
        
        return serializer.value
    }
    
    // MARK: - Initializers
    /// Creates a new empty instance of the object.
    public init() {
        // Initialize
        self.isAnimated = false
    }
    
    /// Creates a new instance
    /// - Parameter value: A serialized string representing the `MangaAnimation`.
    public required init(from value: String) {
        let deserializer = Deserializer(text: value, divider: Divider.animation)
        
        self.isAnimated = deserializer.bool()
        self.delay = deserializer.double()
        self.opacityStart = deserializer.double()
        self.opacityEnd = deserializer.double()
        self.xOffsetStart = deserializer.cgFloat()
        self.xOffsetEnd = deserializer.cgFloat()
        self.yOffsetStart = deserializer.cgFloat()
        self.yOffsetEnd = deserializer.cgFloat()
        self.rotationDegreesStart = deserializer.double()
        self.rotationDegreesEnd = deserializer.double()
        self.repeats = deserializer.bool()
        self.cycles = deserializer.int()
        self.autoReverse = deserializer.bool()
        self.duration = deserializer.double()
    }
    
    /// Creates a new instance of the object with the given values.
    /// - Parameters:
    ///   - delay: The number of seconds to delay before the animation starts.
    ///   - opacityStart: The starting opacity.
    ///   - opacityEnd: The ending opacity.
    ///   - xOffsetStart: The starting X Offset.
    ///   - yOffsetStart: The starting Y Offset,
    ///   - xOffsetEnd: The ending X Offset.
    ///   - yOffsetEnd: The ending Y Offset.
    ///   - rotationDegreesStart: The starting rotation degrees.
    ///   - rotationDegreesEnd: The ending rotation degrees.
    ///   - repeats: If `true` the animation repeats forever.
    ///   - cycles: If `repeats` is `true` this is the number of times the animation repeats. If set to zero (0), the animation will repeat forever.
    ///   - autoReverse: If `true` and `repeats` is `true`, the animation will ping-pong between the starting and ending values.
    ///   - duration: The amount of time in seconds that it takes to complete the animation.
    public init(delay:Double = 0.5, opacityStart:Double = 1.0, opacityEnd: Double = 1.0, xOffsetStart:CGFloat = 0.0, yOffsetStart:CGFloat = 0.0, xOffsetEnd:CGFloat = 0.0, yOffsetEnd:CGFloat = 0.0, rotationDegreesStart:Double = 0.0, rotationDegreesEnd:Double = 0.0, repeats:Bool = false, cycles:Int = 0, autoReverse:Bool = true, duration:Double = 1.0) {
        // Initialize
        self.isAnimated = true
        self.delay = delay
        self.opacityStart = opacityStart
        self.opacityEnd = opacityEnd
        self.xOffsetStart = xOffsetStart
        self.yOffsetStart = yOffsetStart
        self.xOffsetEnd = xOffsetEnd
        self.yOffsetEnd = yOffsetEnd
        self.rotationDegreesStart = rotationDegreesStart
        self.rotationDegreesEnd = rotationDegreesEnd
        self.repeats = repeats
        self.cycles = cycles
        self.autoReverse = autoReverse
        self.duration = duration
    }
    
    // MARK: - Functions
    /// Resets the animation to its default positions before drawing and animating a page.
    public func reset() {
        currentOpacity = opacityStart
        currentOffsetX = xOffsetStart
        currentOffsetY = yOffsetStart
        currentRotationDegrees = rotationDegreesStart
    }
}
