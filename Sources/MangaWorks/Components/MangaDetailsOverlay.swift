//
//  DetailsOverlay.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 6/15/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SwiftUIGamepad
import SoundManager

/// Displays a zoom in detail of a text item in the manga.
public struct MangaDetailsOverlay: View {

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - detailsTitle: The detail title to display.
    ///   - detailsText: The body of the detail to display.
    ///   - isGamepadConnected: If `true` a gamepad is connected to the device.
    public init(detailsTitle: String = "", detailsText: String = "", isGamepadConnected: Binding<Bool>) {
        self.detailsTitle = detailsTitle
        self.detailsText = detailsText
        self._isGamepadConnected = isGamepadConnected
    }
    
    // MARK: - Properties
    /// The detail title to display.
    public var detailsTitle:String = ""
    
    /// The body of the detail to display.
    public var detailsText:String = ""
    
    // MARK: - States
    /// If `true` a gamepad is connected to the device.
    @Binding public var isGamepadConnected:Bool
    
    // MARK: - Computed Properties
    /// Returns the padding based on the device.
    private var padding:CGFloat {
        if HardwareInformation.isPhone {
            return 20
        } else {
            return 100
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        VStack {
            if HardwareInformation.isPhone {
                iPhoneContents()
            } else {
                iPadContents()
            }
        }
        .ignoresSafeArea()
        .frame(width: CGFloat(HardwareInformation.screenWidth), height: CGFloat(HardwareInformation.screenHeight))
        .background(Color(fromHex: "000000BB"))
        
    }
    
    // MARK: - Functions
    /// Draws the iPhone body
    /// - Returns: Returns a view containing the iPhone body.
    @ViewBuilder func iPhoneContents() -> some View {
        ScrollView {
            VStack {
                Text(detailsTitle)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .padding(.bottom)
                
                Text(markdown: detailsText)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, padding)
            }
        }
        .frame(width: CGFloat(HardwareInformation.screenWidth - 4), height: CGFloat(HardwareInformation.screenHeight - HardwareInformation.tipPaddingVertical))
        
        if isGamepadConnected {
            HStack {
                GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonAImage, title: "Close", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: MangaWorks.actionForegroundColor)
            }
        } else {
            MangaIconButton(iconName: "x.circle.fill") {
                SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                Execute.onMain {
                    MangaBook.shared.showDetailView = false
                }
            }
            .padding(.top)
        }
    }
    
    /// Draws the iPad body.
    /// - Returns: Returns a view containing the iPad body.
    @ViewBuilder func iPadContents() -> some View {
        VStack {
            Text(detailsTitle)
                .font(.largeTitle)
                .foregroundColor(Color.white)
                .padding(.bottom)
            
            Text(markdown: detailsText)
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, padding)
        }
        
        if isGamepadConnected {
            HStack {
                GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonAImage, title: "Close", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: MangaWorks.actionForegroundColor)
            }
        } else {
            MangaIconButton(iconName: "x.circle.fill") {
                SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                Execute.onMain {
                    MangaBook.shared.showDetailView = false
                }
            }
            .padding(.top)
        }
    }
}

#Preview {
    MangaDetailsOverlay(isGamepadConnected: .constant(false))
}
