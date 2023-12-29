//
//  File.swift
//  
//
//  Created by Kevin Mullins on 12/29/23.
//

import Foundation
import SwiftUI
import Observation

@Observable open class MangaSpeechBalloon {
    
    // MARK: - Enumerations
    public enum BalloonType:String {
        case talk = "BalloonTalk"
        case think = "BalloonThink"
        case loudSpeaker = "BalloonLoud"
        case robot = "BalloonRobot"
        case electronic = "BalloonElectronic"
        case scream = "BalloonScream"
        case telepathic = "BalloonTelepathic"
        case whisper = "BalloonWhisper"
        case weak = "BalloonWeak"
    }
    
    public enum TailOrientation {
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
        
        var x:CGFloat {
            if self == .topLeading || self == .topTrailing {
                return 1.0
            } else {
                return 0.0
            }
        }
        
        var y:CGFloat {
            if self == .bottomLeading || self == .topLeading {
                return 1.0
            } else {
                return 0.0
            }
        }
        
        var alignment:Alignment {
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
}
