//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/26/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SpriteKit
import SoundManager

/// Displays a full size scroll and zoomable image.
public struct MangaImageViewer: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - imageName: The name of the image file to display.
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - backgroundColor: The background color of the page.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(imageSource: MangaWorks.Source = .appBundle, imageName: String = "", uniqueID: String  = "ImageViewer", backgroundColor: Color  = .white, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.imageSource = imageSource
        self.imageName = imageName
        self.uniqueID = uniqueID
        self.backgroundColor = backgroundColor
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The name of the image file to display.
    public var imageName:String = ""
    
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "ImageViewer"
    
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
    
    /// Tracks changes in the manga page orientation.
    @State private var screenOrientation:UIDeviceOrientation = HardwareInformation.deviceOrientation
    
    /// Holds a buffer that allows the image to be fully scrollable and the zoom level changes.
    @State private var zoomBuffer:CGFloat = CGFloat(0.0)
    
    // MARK: - Computed Properties
    /// Returns the size of the footer text.
    private var footerTextSize:Float {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 12
        }
    }
    
    /// Gets the width of a footer column.
    private var footerColumnWidth:CGFloat {
        return MangaPageScreenMetrics.screenHalfWidth / 3.0
    }
    
    /// Gets the inset for the comic page.
    private var insetHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(20.0)
        } else {
            return CGFloat(90.0)
        }
    }
    
    /// Gets the inset for the comic page.
    private var insetVertical:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(125.0)
        } else {
            return CGFloat(90.0)
        }
    }
    
    /// Returns the border color based on the device.
    private var borderColor:Color {
        if HardwareInformation.isPhone {
            return .clear
        } else {
            return .black
        }
    }
    
    /// Defines the header padding based on the device.
    private var headerPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 30.0
        } else {
            return 20.0
        }
    }
    
    /// Defines the footer padding based on the device.
    private var footerPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 40.0
        } else {
            return 10.0
        }
    }
    
    /// Defines the zoom button size based on the device.
    private var zoomButtonSize:CGFloat {
        if HardwareInformation.isPhone {
            return 12.0
        } else {
            switch screenOrientation {
            case .landscapeLeft, .landscapeRight:
                return 14.0
            default:
                return 24.0
            }
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, borderColor: borderColor, backgroundColor: backgroundColor) {
                pageBodyContents(orientation: screenOrientation)
            }
            #if os(iOS)
            .statusBar(hidden: true)
            #endif
            
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
                buttonBUsage(viewID: uniqueID, "Show the **Action Menu**.")
            })
        }
        .onRotate {orientation in
            screenOrientation = HardwareInformation.correctOrientation(orientation)
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
        .onGamepadButtonB(viewID: uniqueID) { isPressed in
            if isPressed {
                MangaBook.shared.changeView(viewID: "[ACTION]")
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
    /// Draws the contents of the page.
    /// - Parameter orientation: The current screen orientation.
    /// - Returns: Returns a view containing the body.
    @ViewBuilder func pageBodyContents(orientation:UIDeviceOrientation) -> some View {
        ZStack {
            ZoomView(minimumZoom: 0.50, maximumZoom: 2.0, initialZoom: 1.0, buttonSize: zoomButtonSize, zoomChangedHandler: {zoom in
                let factor = CGFloat(10.0 * zoom)
                zoomBuffer = CGFloat(30 * factor)
            }) {
                pageContents()
            }
            .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
        }
        .background(.black)
    }
    
    /// Creates the main body of the cover.
    /// - Returns: Returns a view representing the body of the cover.
    @ViewBuilder func pageContents() -> some View {
        ZStack {
            if imageSource == .appBundle {
                ScaledImageView(imageName: imageName)
            } else {
                ScaledImageView(imageURL: MangaWorks.urlTo(resource: imageName, withExtension: "jpg"))
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
                SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Flag2_TurnPage", ofType: "mp3"), channel: .channel03)
                MangaBook.shared.changeView(viewID: "[CURRENT]")
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding(.top, headerPadding)
    }
    
    /// Draws the page footer.
    /// - Returns: Returns a view containing the page footer.
    @ViewBuilder func pageFooter() -> some View {
        HStack {
            
            ZStack {
                Text("Chapter: \(MangaBook.shared.currentPage.chapter)")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            ZStack {
                Text("Page: \(MangaBook.shared.currentPage.id) \(MangaBook.shared.currentPage.title)")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.trailing)
            }
            .frame(width: footerColumnWidth)
        }
        .padding(.bottom, footerPadding)
    }
}

#Preview {
    MangaImageViewer()
}
