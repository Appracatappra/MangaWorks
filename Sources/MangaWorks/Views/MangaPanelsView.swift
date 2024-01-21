//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/14/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SpriteKit
import SoundManager

/// Displays a full page image as the main contents of the page.
public struct MangaPanelsView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - page: The `MangaPage` to display.
    ///   - backgroundColor: The background color of the page.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID: String = "FullPageView", page: MangaPage = MangaPage(id: "00", pageType: .panelsPage), backgroundColor: Color = .white, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.uniqueID = uniqueID
        self.page = page
        self.backgroundColor = backgroundColor
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "PanelsView"
    
    // The `MangaPage` to display.
    public var page:MangaPage = MangaPage(id: "00", pageType: .panelsPage)
    
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
    @State private var screenOrientation:UIDeviceOrientation = .unknown
    
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
    
    /// Generates a weather controller with the specifics of the given manga page.
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
        scene.hasGlitch = false
        return scene
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
            return 18.0
        } else {
            return 24.0
        }
    }
    
    /// The padding between the panels based on the device.
    private var panelGutter:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 10.0
        }
    }
    
    /// The padding between the layer elements.
    private var layerPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 0.0
        } else {
            return 10.0
        }
    }
    
    #if os(tvOS)
    /// The column top width.
    private var columnWidthTop:CGFloat {
        return CGFloat(Double(HardwareInformation.screenWidth - 150) / 4.0)
    }

    /// The column bottom width.
    private var columnWidthBottom:CGFloat {
        return CGFloat(Double(HardwareInformation.screenWidth - 150) / 3.0)
    }
    #else
    /// The column top width.
    private var columnWidthTop:CGFloat {
        return CGFloat(Double(HardwareInformation.screenWidth - 20) / 4.0)
    }

    /// The column bottom width.
    private var columnWidthBottom:CGFloat {
        return CGFloat(Double(HardwareInformation.screenWidth - 20) / 3.0)
    }
    #endif
    
    /// The page vertical padding.
    private var pagePaddingVertical:CGFloat {
        return CGFloat(HardwareInformation.deviceVerticalOffset)
    }
    
    /// The adjusted screen width.
    private var screenWidth:CGFloat {
        return CGFloat(HardwareInformation.screenHalfWidth - 80)
    }

    /// The adjusted screen height.
    private var screenHeight:CGFloat {
        return CGFloat(HardwareInformation.screenHeight - 100)
    }
    
    /// The adjusted screen height.
    private var screenHalfHeight:CGFloat {
        return CGFloat(screenHeight / 2.0)
    }
    
    /// If `true`, text should be Abreviated
    private var shouldAbreviate:Bool {
        if HardwareInformation.isPhone {
            switch HardwareInformation.screenWidth {
            case 375:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    /// The height offset based on device.
    private var heightOffset:CGFloat {
        if HardwareInformation.isPhone {
            return 1.5
        } else if HardwareInformation.isPad {
            if HardwareInformation.deviceOrientation == .portrait {
                return 2.0
            } else {
                return 1.5
            }
        } else {
            return 2.0
        }
    }
    
    /// Gets the title of the chapter.
    private var chapter:String {
        if let chapter = MangaBook.shared.getChapter(id: page.chapter) {
            return chapter.title
        } else {
            return page.chapter
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, borderColor: borderColor, backgroundColor: backgroundColor) {
                pageBodyContents(orientation: screenOrientation, layerVisibility: MangaBook.shared.layerVisibility)
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
            // Connect to gamepad
            connectGamepad(viewID: uniqueID, handler: { controller, gamepadInfo in
                isGamepadConnected = true
                buttonMenuUsage(viewID: uniqueID, "Return to the **Cover Page Menu**.")
                leftShoulderUsage(viewID: uniqueID, "Return to the **Previous Page**.")
                rightShoulderUsage(viewID: uniqueID, "Go to the **Next Page**, **Continue Game** or **End Game** based on the state displayed in the right hand corner.")
                buttonAUsage(viewID: uniqueID, "Show or hide **Gamepad Help** or hide any **Tips** currently being displayed.")
                buttonBUsage(viewID: uniqueID, "Show or hide the **Actions Menu**.")
            })
        }
        .onRotate {orientation in
            screenOrientation = orientation
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
        .onGamepadLeftShoulder(viewID: uniqueID) { isPressed, pressure in
            if isPressed {
                if page.previousPage != "" {
                    MangaBook.shared.displayPage(id: page.previousPage)
                }
            }
        }
        .onGamepadRightShoulder(viewID: uniqueID) { isPressed, pressure in
            if isPressed {
                if page.nextPage != "" {
                    MangaBook.shared.displayPage(id: page.nextPage)
                }
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
    @ViewBuilder func pageBodyContents(orientation:UIDeviceOrientation, layerVisibility:MangaLayerManager.ElementVisibility) -> some View {
        ZStack {
            ZoomView(minimumZoom: 0.8, maximumZoom: 2.0, initialZoom: 1.0, buttonSize: zoomButtonSize, zoomChangedHandler: {zoom in
                let factor = CGFloat(10.0 * zoom)
                zoomBuffer = CGFloat(30 * factor)
            }) {
                pageContents(layerVisibility: layerVisibility)
            }
            .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
            
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
    @ViewBuilder func pageContents(layerVisibility:MangaLayerManager.ElementVisibility) -> some View {
        ZStack {
            // Display panels
            MangaLayerManager.panelsOverlay(page: page, width: screenWidth, height: screenHeight, panelGutter: panelGutter)
            
            // Display action selector
            if let hud = page.actions {
                MangaActionSelector(locationID: page.id, title: hud.title, leftSide: hud.leftSide, rightSide: hud.rightSide, maxEntries: hud.maxEntries, boxWidth: screenWidth, boxHeight: screenHalfHeight, pageWidth: screenWidth, pageHeight: screenHeight, isGamepadConnected: $isGamepadConnected)
            }
            
            // Display PIN entry
            if let pin = page.pin {
                if isGamepadConnected {
                    MangaGamePadPinEntry(pin:pin, boxWidth: screenWidth, boxHeight: screenHalfHeight, pageWidth: screenWidth, pageHeight: screenHeight, editorID: "Pin-\(page.id)")
                } else {
                    MangaPinEntryView(pin:pin, boxWidth: screenWidth, boxHeight: screenHalfHeight, pageWidth: screenWidth, pageHeight: screenHeight)
                }
            }
            
            // Display Symbol Entry
            if let symbol = page.symbol {
                if isGamepadConnected {
                    MangaGamePadSymbolEntry(symbol: symbol, boxWidth: screenWidth, boxHeight: screenHalfHeight, pageWidth: screenWidth, pageHeight: screenHeight, editorID: "Symbol-\(page.id)")
                } else {
                    MangaSymbolEntryView(symbol: symbol, boxWidth: screenWidth, boxHeight: screenHalfHeight)
                }
            }
            
            // The details
            ZStack {
                // Overlay Layers
                MangaLayerManager.detailImageOverlay(page: page, layerVisibility: layerVisibility, padding: layerPadding)
                
                MangaLayerManager.captionOverlay(page: page, layerVisibility: layerVisibility, padding: layerPadding)
                
                MangaLayerManager.wordArtOverlay(page: page, layerVisibility: layerVisibility, padding: layerPadding)
                
                MangaLayerManager.balloonOverlay(page: page, layerVisibility: layerVisibility, padding: layerPadding)
            }
            .frame(width: screenWidth, height: screenHeight)
            
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth + zoomBuffer, height: MangaPageScreenMetrics.screenHeight + zoomBuffer)
        .clipped()
        //.padding(.horizontal)
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
            if page.previousPage != "" {
                MangaButton(title: "< Prev", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Flag2_TurnPage", ofType: "mp3"), channel: .channel03)
                    MangaBook.shared.displayPage(id: page.previousPage)
                }
                .padding(.leading)
            }
            
            Spacer()
            
            if page.nextPage != "" {
                MangaButton(title: "Next >", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Flag2_TurnPage", ofType: "mp3"), channel: .channel03)
                    MangaBook.shared.displayPage(id: page.nextPage)
                }
                .padding(.trailing)
            }
        }
        .padding(.top, headerPadding)
    }
    
    /// Draws the page footer.
    /// - Returns: Returns a view containing the page footer.
    @ViewBuilder func pageFooter() -> some View {
        HStack {
            
            ZStack {
                Text("Chapter: \(chapter)")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            if page.hasFunctionsMenu {
                ZStack {
                    if isGamepadConnected {
                        GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: "Actions", scale: MangaPageScreenMetrics.controlButtonScale)
                    } else {
                        MangaButton(title: "Actions", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                            MangaBook.shared.changeView(viewID: "[ACTION]")
                        }
                    }
                }
                .frame(width: footerColumnWidth)
            }
            
            Spacer()
            
            ZStack {
                Text("Page: \(page.id) \(page.title)")
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
    MangaPanelsView(page: MangaPage(id: "00", pageType: .panelsPage))
}
