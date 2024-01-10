//
//  File.swift
//  
//
//  Created by Kevin Mullins on 12/29/23.
//

import Foundation
import CoreImage
import UIKit
import SwiftletUtilities

extension HardwareInformation {
    
    /// Returns the width of the main screen of the device the app is running on divided by two.
    public static var screenHalfWidth:Int {
        let screenSize: CGRect = UIScreen.main.bounds
        #if os(tvOS)
        return Int(screenSize.width / 2.0)
        #else
        // Are we running on an iPad?
        if isPad {
            // Yes, handle the iPad being in the landscape orientation.
            switch deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return Int(screenSize.width / 2.0)
            default:
                return Int(screenSize.width)
            }
        } else {
            // Assume we are always in the portrait orientation.
            return Int(screenSize.width)
        }
        #endif
    }
    
    /// Returns the height of the main screen of the device the app is running on divided by two.
    public static var screenHalfHeight:Int {
        return screenHeight / 2
    }
    
    /// Returns an adjustment ratio to properly scale the app's UI based on the device the app is running on. The app is being designed on an iPad Pro 11-inch so all adjustments are based off of this device's screen width.
    public static var deviceRatioWidth:Float {
        return Float(screenWidth) / 834.0
    }
    
    /// Returns an adjustment ratio to properly scale the app's UI based on the device the app is running on. The app is being designed on an iPad Pro 11-inch so all adjustments are based off of this device's screen height.
    public static var deviceRatioHeight:Float {
        //return Float(screenHeight) / 1194.0
        return Float(screenHeight - (Int(deviceVerticalOffset) * 2)) / 1194.0
    }
    
    /// Returns an offset that is use to correct the aspect ratio for the different device types.
    public static var deviceVerticalOffset:Float {
        if HardwareInformation.isPhone {
            switch HardwareInformation.screenHeight {
            case 667, 736:
                return 20.0
            default:
                return 70.0 //Initially 35.0
            }
        } else {
            return 20.0
        }
    }
    
    /// Returns the padding that is used on the Tips pages based on the given device.
    public static var tipPaddingVertical:Int {
        switch HardwareInformation.screenHeight {
        case 667, 736:
            return 200
        default:
            return 300
        }
    }
    
    /// Defines the overall ratio to scale the app's UI based on the device that it is running on. The app is being designed on an iPad Pro 11-inch so all adjustments are based off of this device's mainscreen.
    public static var deviceRatio:Float {
        if HardwareInformation.isPhone {
            return deviceRatioWidth
        } else {
            if screenWidth == 1024 {
                return HardwareInformation.deviceRatioWidth - 0.04
            } else {
                return HardwareInformation.deviceRatioWidth * HardwareInformation.deviceRatioHeight
            }
        }
    }
}
