//
//  File.swift
//  
//
//  Created by Kevin Mullins on 12/29/23.
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SwiftUIPanoramaViewer

/// Hods a speech balloon that can be displayed on a manga page.
@Observable open class MangaPageSpeechBalloon {
    
    // MARK: - Enumerations
    /// The type of balloon to display.
    public enum BalloonType:String {
        /// A character talking.
        case talk = "BalloonTalk"
        
        /// A character thinking.
        case think = "BalloonThink"
        
        /// A loud speaker.
        case loudSpeaker = "BalloonLoud"
        
        /// A robot speaking.
        case robot = "BalloonRobot"
        
        /// An electronic device speaking.
        case electronic = "BalloonElectronic"
        
        /// A character screaming.
        case scream = "BalloonScream"
        
        /// A telepathic message.
        case telepathic = "BalloonTelepathic"
        
        /// A character whispering.
        case whisper = "BalloonWhisper"
        
        /// A character speaking in a weak voice.
        case weak = "BalloonWeak"
    }
    
    /// Defines the location of the speech balloon tail.
    public enum TailOrientation {
        /// On the top leading edge.
        case topLeading
        
        /// On the top trailing edge.
        case topTrailing
        
        /// On the bottom leading edge.
        case bottomLeading
        
        /// On the bottom trailing edge.
        case bottomTrailing
        
        /// The X offset for the tail.
        public var x:CGFloat {
            if self == .topLeading || self == .topTrailing {
                return 1.0
            } else {
                return 0.0
            }
        }
        
        /// The Y offset for the tail.
        public var y:CGFloat {
            if self == .bottomLeading || self == .topLeading {
                return 1.0
            } else {
                return 0.0
            }
        }
        
        /// The word aligment for the speech balloon.
        public var alignment:Alignment {
            switch self {
            case .topLeading:
                return .bottomLeading
            case .topTrailing:
                return .bottomLeading
            case .bottomLeading:
                return .topLeading
            case .bottomTrailing:
                return.topLeading
            }
        }
    }
    
    // MARK: - Properties
    /// The type of speech balloon.
    public var type:BalloonType = .talk
    
    /// The caption for the balloon.
    public var caption:String = ""
    
    /// Where to draw the tail on the speech balloon.
    public var tail:TailOrientation = .bottomTrailing
    
    /// The font to draw the balloon in.
    public var font:ComicFonts = .KomikaTight
    
    /// The font size to draw the balloon in.
    public var fontSize:Float = 24
    
    /// The font color for the speech balloon.
    public var fontColor:Color = Color.black
    
    /// The box width of the balloon.
    public var boxWidth:Float = 200.0
    
    /// The X offset of the balloon.
    public var xOffset:Float = 0.0
    
    /// The Y offset of the balloon.
    public var yOffset:Float = 0.0
    
    /// The layer visibility of the balloon.
    public var layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways
    
    /// A condition written in the Grace Language that must be met before the balloon is displayed.
    public var condition:String = ""
    
    /// The leading pitch for displaying the balloon.
    public var pitchLeading:Float = 0.0
    
    /// The trailing pitch for displaying the balloon.
    public var pitchTrailing:Float = 0.0
    
    /// The leading yaw for displaying the balloon.
    public var yawLeading:Float = 0.0
    
    /// The trailing yaw for displaying the balloon.
    public var yawTrailing:Float = 0.0
    
    /// The animation for the balloon.
    public var animation:MangaAnimation = MangaAnimation()
    
    /// The voice to read the balloon in.
    public var actor:MangaVoiceActors = .narrator
    
    // MARK: - Computed Properties
    /// Returns a `MangaSheechBalloonView` representing the speech balloon.
    public var view:some View {
        animation.reset()
        return MangaSheechBalloonView(type: type, caption: caption, tail:tail, font: font, fontSize: fontSize * HardwareInformation.deviceRatioWidth, fontColor: fontColor, boxWidth: boxWidth * HardwareInformation.deviceRatioWidth, xOffset: xOffset * HardwareInformation.deviceRatioWidth, yOffset: yOffset * HardwareInformation.deviceRatioHeight).environmentObject(animation)
    }
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - actor: The voice to read the balloon in.
    ///   - caption: The caption for the balloon.
    ///   - type: The type of speech balloon.
    ///   - tail: Where to draw the tail on the speech balloon.
    ///   - font: The font to draw the balloon in.
    ///   - fontSize: The font size to draw the balloon in.
    ///   - fontColor: The font color for the speech balloon.
    ///   - boxWidth: The box width of the balloon.
    ///   - xOffset: The X offset of the balloon.
    ///   - yOffset: The Y offset of the balloon.
    ///   - layerVisibility: The layer visibility of the balloon.
    ///   - pitch: The pitch to display the balloon at.
    ///   - yaw: The yaw to display the balloon at.
    ///   - animation: The animation for the balloon.
    ///   - condition: A condition written in the Grace Language that must be met before the balloon is displayed.
    public init(actor:MangaVoiceActors = .narrator, caption:String, type:BalloonType = .talk, tail:TailOrientation = .bottomTrailing, font:ComicFonts = .KomikaTight, fontSize:Float = 24, fontColor:Color = Color.black, boxWidth:Float = 200.0, xOffset:Float = 0.0, yOffset:Float = 0.0, layerVisibility:MangaLayerManager.ElementVisibility = .displayAlways, pitch:Float = 0.0, yaw:Float = 0.0, animation:MangaAnimation = MangaAnimation(), condition:String = "") {
        // Initialize
        self.actor = actor
        self.type = type
        self.caption = caption
        self.tail = tail
        self.font = font
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.boxWidth = boxWidth
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.layerVisibility = layerVisibility
        self.pitchLeading = PanoramaManager.leadingTarget(pitch)
        self.pitchTrailing = PanoramaManager.trailingTarget(pitch)
        self.yawLeading = PanoramaManager.leadingTarget(yaw)
        self.yawTrailing = PanoramaManager.trailingTarget(yaw)
        self.animation = animation
        self.condition = condition
    }
}
