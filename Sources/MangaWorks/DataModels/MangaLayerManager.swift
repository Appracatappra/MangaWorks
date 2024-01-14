//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SpriteKit

/// Manages all of the layers that are built up to create a MangaWorks page. The layers include the panels and all of the elements that overlay to create the final displayed page.
open class MangaLayerManager {
    // MARK: - Events
    /// Handler for a layout layer changing.
    public typealias ChangeHandler = () -> Void
    
    // MARK: - Enumerations
    /// Defines the condition that must be met to display an element in the layout system.
    public enum ElementVisibility: Int {
        /// No interaction is required.
        case empty = 0
        
        /// None of the elements will be displayed.
        case displayNothing
        
        /// All of the elements will always be dislayed.
        case displayAlways
        
        /// Display the result of a search interaction.
        case displaySearch
        
        /// Display the result of a secondary search interaction.
        case displaySearchAlt
        
        /// Display the result of a use interaction.
        case displayUse
        
        /// Display the result of a secondary use interaction.
        case displayUseAlt
        
        /// Display the result of a talk interaction.
        case displayTalk
        
        /// Display the result of a secondary talk interaction.
        case displayTalkAlt
        
        /// Display the result of a examine interaction.
        case displayExamine
        
        /// Display the result of a secondary examine interaction.
        case displayExamineAlt
        
        /// Display the result of a navigation interaction.
        case displayNav
        
        /// Display the result of a secondary navigation interaction.
        case displayNavAlt
        
        /// Display the result of a attack interaction.
        case displayAttack
        
        /// Display the result of a secondary attack interaction.
        case displayAttackAlt
        
        /// Display the result of a havk interaction.
        case displayHack
        
        /// Display the result of a secondary hack interaction.
        case displayHackAlt
        
        /// Display the result of a call interaction.
        case displayCall
        
        /// Display the result of a secondary call interaction.
        case displayCallAlt
        
        /// Display the result of a next location interaction.
        case displayNextLocation
        
        /// Display the result of a conversation A interaction.
        case displayConversationA
        
        /// Display the result of a conversation B interaction.
        case displayConversationB
        
        /// Display  a conversation A interaction result.
        case displayConversationResultA
        
        /// Display  a conversation B interaction result.
        case displayConversationResultB
        
        
        // MARK: - Computed Properties
        /// Returns the enum as a string value.
        public var asString:String {
            switch self {
            case .empty:
                return "empty"
            case .displayNothing:
                return "displayNothing"
            case .displayAlways:
                return "displayAlways"
            case .displaySearch:
                return "displaySearch"
            case .displaySearchAlt:
                return "displaySearchAlt"
            case .displayUse:
                return "displayUse"
            case .displayUseAlt:
                return "displayUseAlt"
            case .displayTalk:
                return "displayTalk"
            case .displayTalkAlt:
                return "displayTalkAlt"
            case .displayExamine:
                return "displayExamine"
            case .displayExamineAlt:
                return "displayExamineAlt"
            case .displayNav:
                return "displayNav"
            case .displayNavAlt:
                return "displayNavAlt"
            case .displayAttack:
                return "displayAttack"
            case .displayAttackAlt:
                return "displayAttackAlt"
            case .displayHack:
                return "displayHack"
            case .displayHackAlt:
                return "displayHackAlt"
            case .displayCall:
                return "displayCall"
            case .displayCallAlt:
                return "displayCallAlt"
            case .displayNextLocation:
                return "displayNextLocation"
            case .displayConversationA:
                return "displayConversationA"
            case .displayConversationB:
                return "displayConversationB"
            case .displayConversationResultA:
                return "displayConversationResultA"
            case .displayConversationResultB:
                return "displayConversationResultB"
            }
        }
        
        // MARK: - Functions
        /// Gets the value from a `String` and defaults to `empty` if the conversion is invalid.
        /// - Parameter value: The value holding the string to convert.
        public mutating func from(_ value:String) {
            switch value {
            case "empty":
                self = .empty
            case "displayNothing":
                self = .displayNothing
            case "displayAlways":
                self = .displayAlways
            case "displaySearch":
                self = .displaySearch
            case "displaySearchAlt":
                self = .displaySearchAlt
            case "displayUse":
                self = .displayUse
            case "displayUseAlt":
                self = .displayUseAlt
            case "displayTalk":
                self = .displayTalk
            case "displayTalkAlt":
                self = .displayTalkAlt
            case "displayExamine":
                self = .displayExamine
            case "displayExamineAlt":
                self = .displayExamineAlt
            case "displayNav":
                self = .displayNav
            case "displayNavAlt":
                self = .displayNavAlt
            case "displayAttack":
                self = .displayAttack
            case "displayAttackAlt":
                self = .displayAttackAlt
            case "displayHack":
                self = .displayHack
            case "displayHackAlt":
                self = .displayHackAlt
            case "displayCall":
                self = .displayCall
            case "displayCallAlt":
                self = .displayCallAlt
            case "displayNextLocation":
                self = .displayNextLocation
            case "displayConversationA":
                self = .displayConversationA
            case "displayConversationB":
                self = .displayConversationB
            case "displayConversationResultA":
                self = .displayConversationResultA
            case "displayConversationResultB":
                self = .displayConversationResultB
            default:
                self = .empty
            }
        }
        
        /// Gets the value from an `Int` and defaults to `empty` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = ElementVisibility(rawValue: value) {
                self = enumeration
            } else {
                self = .empty
            }
        }
        
    }
    
    // MARK: - Static Properties
    /// The current layout pattern for the Caption Layer.
    public static var captionLayout:String = ""
    
    /// The current layout pattern for the Balloon Layer.
    public static var balloonLayout:String = ""
    
    /// The current layout pattern for the Detail Image Layer.
    public static var detailImageLayout:String = ""
    
    /// The current layout pattern for the Word Art Layer.
    public static var wordArtLayout:String = ""
    
    // MARK: - Static Functions
    /// Updates the Caption Layout based on the current panorama rotation. If the Caption Layout changed, call the given change handler.
    /// - Parameters:
    ///   - layout: The new Caption Layout based on the panorama rotation.
    ///   - changed: The handler that is called if the Caption Layout has changed.
    public static func updateCaptionLayout(_ layout:String, changed:ChangeHandler? = nil) {
        if layout != captionLayout {
            captionLayout = layout
            if let changed = changed {
                changed()
            }
        }
    }
    
    /// Updates the Caption Layout based on the current panorama rotation. If the Caption Layout changed, call the given change handler.
    /// - Parameters:
    ///   - layout: The new Caption Layout based on the panorama rotation.
    ///   - changed: The handler that is called if the Caption Layout has changed.
    public static func updateBalloonLayout(_ layout:String, changed:ChangeHandler? = nil) {
        if layout != balloonLayout {
            balloonLayout = layout
            if let changed = changed {
                changed()
            }
        }
    }
    
    /// Updates the Detail Image Layout based on the current panorama rotation. If the Detail Image Layout changed, call the given change handler.
    /// - Parameters:
    ///   - layout: The new Detail Image Layout based on the panorama rotation.
    ///   - changed: The handler that is called if the Detail Image Layout has changed.
    public static func updateDetailImageLayout(_ layout:String, changed:ChangeHandler? = nil) {
        if layout != detailImageLayout {
            detailImageLayout = layout
            if let changed = changed {
                changed()
            }
        }
    }
    
    /// Updates the Word Art Layout based on the current panorama rotation. If the Word Art Layout changed, call the given change handler.
    /// - Parameters:
    ///   - layout: The new Word Art Layout based on the panorama rotation.
    ///   - changed: The handler that is called if the Word Art Layout has changed.
    public static func updateWordArtLayout(_ layout:String, changed:ChangeHandler? = nil) {
        if layout != wordArtLayout {
            wordArtLayout = layout
            if let changed = changed {
                changed()
            }
        }
    }
    
    /// Generates the Detail Image Overlay for the given location and rotation with the given padding.
    /// - Parameters:
    ///   - page: The `MangaPage` to generate the overlay for.
    ///   - layverVisibility: The layver visibility to generate the overlay for.
    ///   - padding: The padding between the elements and the page edge.
    /// - Returns: A `View` containing the fully laid out overlay.
    @ViewBuilder public static func detailImageOverlay(page:MangaPage, layerVisibility:ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0, padding:CGFloat) -> some View {
        VStack {
            // Top Row
            HStack {
                // Leading
                if let image = page.getDetailImage(at: .topLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.leading, padding + 15.0)
                        .padding(.top, padding + 15.0)
                } else {
                    Spacer()
                }

                // Center
                if let image = page.getDetailImage(at: .topCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.top, padding + 15.0)
                } else {
                    Spacer()
                }

                // Trialing
                if let image = page.getDetailImage(at: .topTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.trailing, padding + 15.0)
                        .padding(.top, padding + 15.0)
                } else {
                    Spacer()
                }
            }

            Spacer()

            // Upper Middle Row
            HStack {
                // Leading
                if let image = page.getDetailImage(at: .upperMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.leading, padding + 15.0)
                } else {
                    Spacer()
                }

                // Center
                if let image = page.getDetailImage(at: .upperMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                } else {
                    Spacer()
                }

                // Trialing
                if let image = page.getDetailImage(at: .upperMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.trailing, padding + 15.0)
                } else {
                    Spacer()
                }
            }

            Spacer()

            // Lower Middle Row
            HStack {
                // Leading
                if let image = page.getDetailImage(at: .lowerMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.leading, padding + 15.0)
                } else {
                    Spacer()
                }

                // Center
                if let image = page.getDetailImage(at: .lowerMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                } else {
                    Spacer()
                }

                // Trialing
                if let image = page.getDetailImage(at: .lowerMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.trailing, padding + 15.0)
                } else {
                    Spacer()
                }
            }

            Spacer()

            // Bottom Row
            HStack {
                // Leading
                if let image = page.getDetailImage(at: .bottomLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.leading, padding + 15.0)
                        .padding(.bottom, padding + 15.0)
                } else {
                    Spacer()
                }
                
                // Center
                if let image = page.getDetailImage(at: .bottomCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.bottom, padding + 15.0)
                } else {
                    Spacer()
                }
                
                // Trailing
                if let image = page.getDetailImage(at: .bottomTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    image.view
                        .padding(.trailing, padding + 15.0)
                        .padding(.bottom, padding + 15.0)
                } else {
                    Spacer()
                }
            }
        }
    }
    
    /// Generates the overlay panels for the given location with the given parameters
    /// - Parameters:
    ///   - location: The location to build the overlay for.
    ///   - width: The width of the container to build the overlay for.
    ///   - height: The height of the container to build the overlay for.
    ///   - padding: The outer edge padding for the overlay.
    /// - Returns: The generated view.
    @ViewBuilder public static func panelsOverlay(page:MangaPage, width:CGFloat, height:CGFloat, panelGutter:CGFloat) -> some View {
        let panelWidth:CGFloat = width / 3.0//(width - (panelGutter * 2.0)) / 3.0
        let panelHeight:CGFloat = height / 4.0 //(height - (panelGutter * 3.0)) / 4.0
        let x = CGFloat(0)
        let y = CGFloat(0)
        let xIncrement:CGFloat = x + panelWidth + panelGutter
        let yIncrement:CGFloat = y + panelHeight + panelGutter
        let column:[CGFloat] = [x, xIncrement, xIncrement * 2.0]
        let row:[CGFloat] = [y, yIncrement, yIncrement * 2.0, yIncrement * 3.0]
        
        Canvas { context, size in
            // Top Row
            // Leading
            if let panel = page.getPanel(at: .topLeading) {
                panel.draw(mainContext: context, x: column[0], y: row[0], width: panelWidth, height: panelHeight)
            }
            
            // Center
            if let panel = page.getPanel(at: .topCenter) {
                panel.draw(mainContext: context, x: column[1], y: row[0], width: panelWidth, height: panelHeight)
            }
            
            // Trailing
            if let panel = page.getPanel(at: .topTrailing) {
                panel.draw(mainContext: context, x: column[2], y: row[0], width: panelWidth, height: panelHeight)
            }
            
            // Upper Middle Row
            // Leading
            if let panel = page.getPanel(at: .upperMiddleLeading) {
                panel.draw(mainContext: context, x: column[0], y: row[1], width: panelWidth, height: panelHeight)
            }
            
            // Center
            if let panel = page.getPanel(at: .upperMiddleCenter) {
                panel.draw(mainContext: context, x: column[1], y: row[1], width: panelWidth, height: panelHeight)
            }
            
            // Trailing
            if let panel = page.getPanel(at: .upperMiddleTrailing) {
                panel.draw(mainContext: context, x: column[2], y: row[1], width: panelWidth, height: panelHeight)
            }
            
            // Lower Middle Row
            // Leading
            if let panel = page.getPanel(at: .lowerMiddleLeading) {
                panel.draw(mainContext: context, x: column[0], y: row[2], width: panelWidth, height: panelHeight)
            }
            
            // Center
            if let panel = page.getPanel(at: .lowerMiddleCenter) {
                panel.draw(mainContext: context, x: column[1], y: row[2], width: panelWidth, height: panelHeight)
            }
            
            // Trailing
            if let panel = page.getPanel(at: .lowerMiddleTrailing) {
                panel.draw(mainContext: context, x: column[2], y: row[2], width: panelWidth, height: panelHeight)
            }
            
            // Bottom Row
            // Leading
            if let panel = page.getPanel(at: .bottomLeading) {
                panel.draw(mainContext: context, x: column[0], y: row[3], width: panelWidth, height: panelHeight)
            }
            
            // Center
            if let panel = page.getPanel(at: .bottomCenter) {
                panel.draw(mainContext: context, x: column[1], y: row[3], width: panelWidth, height: panelHeight)
            }
            
            // Trailing
            if let panel = page.getPanel(at: .bottomTrailing) {
                panel.draw(mainContext: context, x: column[2], y: row[3], width: panelWidth, height: panelHeight)
            }
            
        } .frame(width: width, height: height)
    }
    
    /// Generates the Word Art Overlay for the given location and rotation with the given padding.
    /// - Parameters:
    ///   - page: The `MangaPage` to generate the overlay for.
    ///   - layerVisibility: The layer visibility to generate the overlay for.
    ///   - padding: The padding between the elements and the page edge.
    /// - Returns: A `View` containing the fully laid out overlay.
    @ViewBuilder public static func wordArtOverlay(page:MangaPage, layerVisibility:ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0, padding:CGFloat) -> some View {
        VStack {
            
            // Top Row
            HStack {
                // Leading
                if let word = page.getWordArt(at: .topLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let word = page.getWordArt(at: .topCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                } else {
                    Spacer()
                }
                
                // Trailing
                if let word = page.getWordArt(at: .topTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Upper Middle Row
            HStack {
                // Leading
                if let word = page.getWordArt(at: .upperMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let word = page.getWordArt(at: .upperMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                } else {
                    Spacer()
                }
                
                // Trailing
                if let word = page.getWordArt(at: .upperMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Lower Middle Row
            HStack {
                // Leading
                if let word = page.getWordArt(at: .lowerMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let word = page.getWordArt(at: .lowerMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                } else {
                    Spacer()
                }
                
                // Trailing
                if let word = page.getWordArt(at: .lowerMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Bottom Row
            HStack {
                // Leading
                if let word = page.getWordArt(at: .bottomLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let word = page.getWordArt(at: .bottomCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                } else {
                    Spacer()
                }
                
                // Trailing
                if let word = page.getWordArt(at: .bottomTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    word.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
        }
    }
    
    /// Generates the Caption Overlay for the given location and rotation with the given padding.
    /// - Parameters:
    ///   - location: The `MapLocation` to generate the overlay for.
    ///   - rotation: The Panorama Rotation to generate the overlay for.
    ///   - padding: The padding between the elements and the page edge.
    /// - Returns: A `View` containing the fully laid out overlay.
    @ViewBuilder public static func captionOverlay(page:MangaPage, layerVisibility:ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0, padding:CGFloat) -> some View {
        VStack {
            // Top Row
            HStack {
                // Leading
                if let caption = page.getCaption(at: .topLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let caption = page.getCaption(at: .topCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let caption = page.getCaption(at: .topTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Upper Middle Row
            HStack {
                // Leading
                if let caption = page.getCaption(at: .upperMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let caption = page.getCaption(at: .upperMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let caption = page.getCaption(at: .upperMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Lower Middle Row
            HStack {
                // Leading
                if let caption = page.getCaption(at: .lowerMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let caption = page.getCaption(at: .lowerMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let caption = page.getCaption(at: .lowerMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Bottom Row
            HStack {
                // Leading
                if let caption = page.getCaption(at: .bottomLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let caption = page.getCaption(at: .bottomCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let caption = page.getCaption(at: .bottomTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    caption.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
        }
    }
    
    /// Generates the Balloon Overlay for the given location and rotation with the given padding.
    /// - Parameters:
    ///   - location: The `MapLocation` to generate the overlay for.
    ///   - rotation: The Panorama Rotation to generate the overlay for.
    ///   - padding: The padding between the elements and the page edge.
    /// - Returns: A `View` containing the fully laid out overlay.
    @ViewBuilder
    static func balloonOverlay(page:MangaPage, layerVisibility:ElementVisibility = .empty, pitch:Float = 0.0, yaw:Float = 0.0, padding:CGFloat) -> some View {
        
        VStack {
            // Top Row
            HStack {
                // Leading
                if let balloon = page.getBalloon(at: .topLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let balloon = page.getBalloon(at: .topCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let balloon = page.getBalloon(at: .topTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Upper Middle Row
            HStack {
                // Leading
                if let balloon = page.getBalloon(at: .upperMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let balloon = page.getBalloon(at: .upperMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let balloon = page.getBalloon(at: .upperMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Lower Middle Row
            HStack {
                // Leading
                if let balloon = page.getBalloon(at: .lowerMiddleLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let balloon = page.getBalloon(at: .lowerMiddleCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let balloon = page.getBalloon(at: .lowerMiddleTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
            
            Spacer()
            
            // Bottom Row
            HStack {
                // Leading
                if let balloon = page.getBalloon(at: .bottomLeading, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.leading, padding)
                } else {
                    Spacer()
                }
                
                // Center
                if let balloon = page.getBalloon(at: .bottomCenter, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                } else {
                    Spacer()
                }
                
                // Leading
                if let balloon = page.getBalloon(at: .bottomTrailing, for: layerVisibility, pitch: pitch, yaw: yaw) {
                    balloon.view
                        .padding(.trailing, padding)
                } else {
                    Spacer()
                }
            }
        }
    }
}
