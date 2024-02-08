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
import SoundManager
import ODRManager

/// Displays a full page image as the main contents of the page.
public struct MangaFullPageView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - page: The `MangaPage` to display.
    ///   - backgroundColor: The background color of the page.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(imageSource: MangaWorks.Source = .appBundle, uniqueID: String = "FullPageView", page: MangaPage = MangaPage(id: "00", pageType: .fullPageImage), backgroundColor: Color = .white, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.imageSource = imageSource
        self.uniqueID = uniqueID
        self.page = page
        self.backgroundColor = backgroundColor
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
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
    
    /// Tracks changes in the manga page orientation.
    @State private var screenOrientation:UIDeviceOrientation = HardwareInformation.deviceOrientation
    
    /// Holds a buffer that allows the image to be fully scrollable and the zoom level changes.
    @State private var zoomBuffer:CGFloat = CGFloat(0.0)
    
    /// HACK: I need this key to force a redraw of the entire SwiftUI view chain.
    @State var redrawKey:String = ""
    
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
            return CGFloat(150.0)
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
            // HACK: I'm updating `redrawkey` when I need to force the entire view to redraw.
            outerContentContainer(reloadKey: redrawKey)
        }
        .onAppear {
            connectGamepad(viewID: uniqueID, handler: { controller, gamepadInfo in
                isGamepadConnected = true
                buttonAUsage(viewID: uniqueID, "Show or hide **Gamepad Help**.")
                buttonBUsage(viewID: uniqueID, "Show the **Action Menu**.")
            })
            
            // Display quicktips
            if MangaStateManager.showFullPageQuicktip {
                MangaBook.shared.detailTitle = "Quicktips"
                MangaBook.shared.detailText = "Use the top right hand **Zoom Controls** to adjust **Page Size** then drag to pan around the page.\n\nUse the top **< Prev** and **Next >** buttons to move between pages.\n\nUse the bottom **Action Menu** to select special actions or return to the **Main Menu**."
                MangaBook.shared.showDetailView = true
                MangaStateManager.showFullPageQuicktip = false
            }
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
    /// Holds the outer most contents of the view.
    /// - Parameter reloadKey: Change this key when you want the entire view to redraw.
    /// - Returns: A View containing the main contents of the screen.
    @ViewBuilder func outerContentContainer(reloadKey:String) -> some View {
        MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, borderColor: borderColor, backgroundColor: backgroundColor) {
            pageBodyContents(orientation: screenOrientation)
        }
        #if os(iOS)
        .statusBar(hidden: true)
        #endif
        
        MangaPageOverlayView(uniqueID: uniqueID) {
            pageOverlayContents()
        }
        
        // Display details.
        if MangaBook.shared.showDetailView {
            MangaDetailsOverlay(detailsTitle: MangaBook.shared.detailTitle, detailsText: MangaBook.shared.detailText, isGamepadConnected: $isGamepadConnected)
                .ignoresSafeArea()
        }
        
        // Display gamepad help
        if showGamepadHelp {
            GamepadHelpOverlay()
        }
        
        // Display gamepad required.
        if isGamepadRequired && !isGamepadConnected {
            GamepadRequiredOverlay()
        }
        
        // Display On-Demand Resource Loading.
        if OnDemandResources.isLoadingResouces {
            ODRContentLoadingOverlay(onLoadedSuccessfully: {
                // Handle the load completing ...
                OnDemandResources.isLoadingResouces = false
                redrawKey = UUID().uuidString
            }, onCancelDownload: {
                // Handle the user wanting to cancel the download ...
                OnDemandResources.isLoadingResouces = false
                MangaBook.shared.changeView(viewID: "[COVER]")
            })
        }
    }
    
    /// Draws the contents of the page.
    /// - Parameter orientation: The current screen orientation.
    /// - Returns: Returns a view containing the body.
    @ViewBuilder func pageBodyContents(orientation:UIDeviceOrientation) -> some View {
        ZStack {
            ZoomView(minimumZoom: 1.0, maximumZoom: 2.0, initialZoom: 1.0, buttonSize: zoomButtonSize, zoomChangedHandler: {zoom in
                let factor = CGFloat(10.0 * zoom)
                zoomBuffer = CGFloat(30 * factor)
            }) {
                pageContents()
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
    @ViewBuilder func pageContents() -> some View {
        ZStack {
            if imageSource == .appBundle {
                Image(page.imageName)
                    .resizable()
                    .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
            } else {
                if let image = MangaWorks.rawImage(name: page.imageName, withExtension: "jpg") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
                }
            }
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth + zoomBuffer, height: MangaPageScreenMetrics.screenHeight + zoomBuffer)
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
            
            HStack {
                if MangaBook.shared.currentPage.hints.count > 0 {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(MangaWorks.actionForegroundColor)
                }
                
                if MangaBook.shared.pageHasItems(mangaPageID: page.id) {
                    Image(systemName: "giftcard.fill")
                        .font(.system(size: 18))
                        .foregroundColor(MangaWorks.actionForegroundColor)
                }
                
                if page.map != "" {
                    Image(systemName: "map.circle")
                        .font(.system(size: 18))
                        .foregroundColor(MangaWorks.actionForegroundColor)
                }
                
                if page.blueprints != "" {
                    Image(systemName: "building.2.crop.circle")
                        .font(.system(size: 18))
                        .foregroundColor(MangaWorks.actionForegroundColor)
                }
            }
            .padding(.trailing, 30)
            
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
                Text("Chapter: \(page.chapter)")
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
    MangaFullPageView(imageSource: .packageBundle, page: MangaPage(id: "00", pageType: .fullPageImage, imageName: "MysticManor01").addWeather(weather: .rain))
}
