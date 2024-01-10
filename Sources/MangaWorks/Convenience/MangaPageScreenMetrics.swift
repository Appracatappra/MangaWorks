//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/7/24.
//

import Foundation
import SwiftletUtilities
import LogManager
import SpeechManager
import GraceLanguage
import SwiftUIPanoramaViewer
import SwiftUI
import SoundManager
import SimpleSerializer
import Observation
import ODRManager

/// Defines some common screne metrics for a `MangaPage` based on the device the app is running on.
open class MangaPageScreenMetrics {
    
    // MARK: - Static Properties
    /// The screen width as a `CGFloat`.
    public static var screenWidth:CGFloat {
        return CGFloat(HardwareInformation.screenWidth)
    }
    
    /// The screen half width as a `CGFloat`.
    public static var screenHalfWidth:CGFloat {
        return CGFloat(HardwareInformation.screenHalfWidth)
    }
    
    /// The screen height as a `CGFloat`.
    public static var screenHeight:CGFloat {
        return CGFloat(HardwareInformation.screenHeight)
    }
    
    /// The screen half height as a `CGFloat`.
    public static var screenHalfHeight:CGFloat {
        return CGFloat(HardwareInformation.screenHalfHeight)
    }
    
    /// The scaling factor for a manga page.
    public static var mangaPageScale:CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        
        var screenWidth = CGFloat(screenSize.width)
        
        if HardwareInformation.isPad {
            screenWidth -= CGFloat(100)
        }
        
        return screenWidth / CGFloat(2996.0)
    }
    
    /// The scaling factor for a control button on a `MangaPage`.
    public static var controlButtonScale:Float {
        #if os(tvOS)
        return 0.25
        #else
        if HardwareInformation.isPhone {
            return 0.15
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 0.18
            default:
                return 0.25
            }
        } else {
            return 0.25
        }
        #endif
    }
    
    /// The default size for a control button font andjusts by the machine.
    public static var controlButtonFontSize:Float {
        return 128.0 * controlButtonScale
    }
    
    /// The scale factor for a character avatar.
    public static var avatarScale:Float {
        if HardwareInformation.isPhone {
            return 0.30
        } else {
            return 0.5
        }
    }
    
    /// The scaling factor for a touch zone.
    public static var touchZoneScale:CGFloat {
        return screenWidth / CGFloat(1024.0)
    }
}
