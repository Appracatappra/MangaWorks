//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/8/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SpriteKit

public struct MangaFullPageView: View {
    
    // MARK: - Initializers
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "FullPageView"
    
    // The `MangaPage` to display.
    public var page:MangaPage = MangaPage(id: "00", pageType: .fullPageImage)
    
    /// The background color of the page.
    public var backgroundColor: Color = .white
    
    /// If `true`, a gamepad is required to run the app.
    public var isGamepadRequired:Bool = false
    
    /// If `true`, the app is attached to Game Center.
    public var isAttachedToGameCenter:Bool = false
    
    // MARK: - States
    /// If `true`, show the gamepad help overlay.
    @State private var showGamepadHelp:Bool = false
    
    /// If `true`, a gamepad is connected to the device the app is running on.
    @State private var isGamepadConnected:Bool = false
    
    // MARK: - Computed Properties
    /// Returns the size of the footer text.
    private var footerTextSize:Float {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 12
        }
    }
    
    /// Returns the menu font size based on the device the app is running on.
    private var menuSize:Float {
        switch HardwareInformation.screenWidth {
        case 744:
            return 24
        case 1024:
            return 24
        default:
            if HardwareInformation.isPhone {
                return 18
            } else if HardwareInformation.isPad {
                switch HardwareInformation.deviceOrientation {
                case .landscapeLeft, .landscapeRight:
                    return 24
                default:
                    return 24
                }
            } else {
                return 24
            }
        }
    }
    
    /// The card width.
    private var cardWidth:Float {
        return Float(HardwareInformation.screenHalfWidth - 100)
    }
    
    /// Gets the inset for the comic page.
    private var inset:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(80.0)
        } else {
            return CGFloat(100.0)
        }
    }
    
    private var weatherScene: SKScene {
        let scene = MangaPageWeatherScene.shared
        scene.size = HardwareInformation.screenSize
        scene.scaleMode = .fill
        scene.hasRain = page.hasRain
        scene.hasFog = page.hasFog
        scene.hasLightning = page.hasLightning
        scene.hasFallingLeaves = page.hasFallingLeaves
        scene.hasBlownPaper = page.hasBlownPaper
        scene.hasBokeh = page.hasBokeh
        //scene.hasGlitch = dataStore.currentGame.getBool("arHacked")
        return scene
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, backgroundColor: backgroundColor) {
                pageBodyContents()
            }
            
            MangaPageOverlayView(uniqueID: uniqueID) {
                pageOverlayContents()
            }
            
            // Display gamepad help
            if showGamepadHelp {
                GamepadHelpOverlay()
            }
            
            // Display gamepad required.
            if isGamepadRequired && !isGamepadConnected {
                GamepadRequiredOverlay()
            }
        }
        .onAppear {
            connectGamepad(viewID: uniqueID, handler: { controller, gamepadInfo in
                isGamepadConnected = true
                buttonAUsage(viewID: uniqueID, "Show or hide **Gamepad Help**.")
            })
        }
        .onDisappear {
            disconnectGamepad(viewID: uniqueID)
        }
        .onGampadAppBecomingActive(viewID: uniqueID) {
            reconnectGamepad()
        }
        .onGamepadDisconnected(viewID: uniqueID) { controller, gamepadInfo in
            isGamepadConnected = false
        }
        .onGamepadButtonA(viewID: uniqueID) { isPressed in
            if isPressed {
                showGamepadHelp = !showGamepadHelp
            }
        }
        #if os(tvOS)
        .onMoveCommand { direction in
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Move: \(direction)")
        }
        .onExitCommand {
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Exit")
        }
        .onPlayPauseCommand {
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Play/Pause")
        }
        #endif
    }
    
    // MARK: - Functions
    @ViewBuilder func pageBodyContents() -> some View {
        ZStack {
            pageContents()
            
            // Weather system
            if page.hasWeather {
                SpriteView(scene: weatherScene, options: [.allowsTransparency])
                    .frame(width: MangaPageScreenMetrics.screenHalfWidth, height: MangaPageScreenMetrics.screenHeight, alignment: .center)
                    .clipped()
                    .allowsHitTesting(false)
            }
        }
    }
    
    /// Creates the main body of the cover.
    /// - Returns: Returns a view representing the body of the cover.
    @ViewBuilder func pageContents() -> some View {
        if imageSource == .appBundle {
            Image(page.imageName)
                .resizable()
        } else {
            if let image = MangaWorks.rawImage(name: page.imageName, withExtension: "jpg") {
                Image(uiImage: image)
                    .resizable()
            }
        }
    }
    
    /// Draws the header and footer overlay contents.
    /// - Returns: Returns a view containing the header and footer.
    @ViewBuilder func pageOverlayContents() -> some View {
        VStack {
            pageheader()
            
            Spacer()
            
            pageFooter()
        }
    }
    
    /// Draws the page header.
    /// - Returns: Returns a view containing the page header.
    @ViewBuilder func pageheader() -> some View {
        HStack {
            MangaButton(title: "Back", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                MangaBook.shared.displayPage(id: "<<")
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    /// Draws the page footer.
    /// - Returns: Returns a view containing the page footer.
    @ViewBuilder func pageFooter() -> some View {
        HStack {
            
            Text("Notebook")
                .font(ComicFonts.Komika.ofSize(footerTextSize))
                .foregroundColor(.black)
                .padding(.leading)
            
            Spacer()
            
            Text("Notes: ")
                .font(ComicFonts.Komika.ofSize(footerTextSize))
                .foregroundColor(.black)
                .padding(.trailing)
        }
        .padding(.bottom, 10)
    }
}

#Preview {
    MangaFullPageView(imageSource: .packageBundle, page: MangaPage(id: "00", pageType: .fullPageImage, imageName: "MysticManor01").addWeather(weather: .cityStorm))
}
