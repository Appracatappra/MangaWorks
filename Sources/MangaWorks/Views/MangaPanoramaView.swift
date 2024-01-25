//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/15/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SpriteKit
import SwiftUIPanoramaViewer
import SoundManager
import SpeechManager

/// Displays a full page image as the main contents of the page.
public struct MangaPanoramaView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - page: The `MangaPage` to display.
    ///   - backgroundColor: The background color of the page.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID: String = "FullPageView", page: MangaPage = MangaPage(id: "00", pageType: .panoramaPage), backgroundColor: Color = .white, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.uniqueID = uniqueID
        self.page = page
        self.backgroundColor = backgroundColor
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "PanoramaView"
    
    // The `MangaPage` to display.
    public var page:MangaPage = MangaPage(id: "00", pageType: .panoramaPage)
    
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
    
    /// If `true`, show the navigation marker.
    @State var showNavigationMarker:Bool = false
    
    /// The currently active interaction.
    @State var interaction:MangaPageInteraction? = nil
    
    /// The currently active navigation point.
    @State var nextNavPoint:MangaPageNavigationPoint? = nil
    
    /// The current rotation pitch.
    @State var rotationPitch:Float = 0.0
    
    /// The current rotation yaw.
    @State var rotationYaw:Float = 0.0
    
    /// The current rotation indicator position.
    @State var rotationIndicator:Float = 0.0
    
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
    
    /// Binds a UI Image to a given image name.
    /// - Parameter name: The name of the image to bind.
    /// - Returns: Returns the bound image for the name.
    func bindImage(_ name:String) -> Binding<UIImage?> {
      return .init(
        get: { UIImage(named: name) },
        set: { let _ = $0 }
      )
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
                pageBodyContents(orientation: screenOrientation, pageID: MangaBook.shared.currentPageID)
            }
            #if os(iOS)
            .statusBar(hidden: true)
            #endif
            
            // Display header and footer
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
    @ViewBuilder func pageBodyContents(orientation:UIDeviceOrientation, pageID:String ) -> some View {
        ZStack {
            pageContents(pageID: pageID)
            
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
    @ViewBuilder func pageContents(pageID: String) -> some View {
        ZStack {
            // Display Panorama
            PanoramaViewer(image: bindImage(page.imageName), panoramaType: .spherical, controlMethod: .touch, backgroundColor: .white,
            cameraMoved: { pitch, yaw, roll in
                // TODO: Showing Pitch and Yaw for building out the game.
                Debug.log("pitch: \(Int(pitch)), yaw: \(Int(yaw))")
                
                // Update content based on rotation
                Execute.onMain {
                    let page = MangaBook.shared.currentPage
                    nextNavPoint = page.navigationPointHit(pitch: pitch, yaw: yaw)
                    showNavigationMarker = (nextNavPoint != nil)
                    
                    rotationIndicator = yaw

                    if MangaBook.shared.layerVisibility != .empty {
                        MangaBook.shared.layerVisibility = .empty
                    }

                    MangaLayerManager.updateCaptionLayout(page.getCaptionLayout(pitch: pitch, yaw: yaw), changed: {
                        rotationPitch = pitch
                        rotationYaw = yaw
                    })
                    MangaLayerManager.updateBalloonLayout(page.getBalloonLayout(pitch: pitch, yaw: yaw), changed: {
                        rotationPitch = pitch
                        rotationYaw = yaw
                    })
                    MangaLayerManager.updateWordArtLayout(page.getWordArtLayout(pitch: pitch, yaw: yaw), changed: {
                        rotationPitch = pitch
                        rotationYaw = yaw
                    })
                    MangaLayerManager.updateDetailImageLayout(page.getDetailImageLayout(pitch: pitch, yaw: yaw), changed: {
                        rotationPitch = pitch
                        rotationYaw = yaw
                    })

                    interaction = page.interactionHit(pitch: pitch, yaw: yaw)

                    // Read any new text popped up because of the rotation change.
                    if MangaStateManager.autoReadPage {
                        page.readNewText(for: MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw)
                    }
                }
            })
            .frame(width: screenWidth - 10, height: screenHeight + 20)
            
            // The details
            ZStack {
                // Overlay Layers
                MangaLayerManager.detailImageOverlay(page: page, layerVisibility: MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw, padding: layerPadding)
                
                MangaLayerManager.captionOverlay(page: page, layerVisibility:  MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw, padding: layerPadding)
                
                MangaLayerManager.wordArtOverlay(page: page, layerVisibility:  MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw, padding: layerPadding)
                
                MangaLayerManager.balloonOverlay(page: page, layerVisibility:  MangaBook.shared.layerVisibility, pitch: rotationPitch, yaw: rotationYaw, padding: layerPadding)
            }
            .frame(width: screenWidth, height: screenHeight)
            
            // Display inline conversations
            if MangaBook.shared.layerVisibility == .displayConversationA {
                if let conversation = page.conversationA?.appendDoneIfNeeded() {
                    MangaConversationView(locationID: "Conversation", portrait: conversation.portrait, name: conversation.name, message: conversation.message, leftSide: conversation.leftSide, rightSide: conversation.rightSide, maxEntries: conversation.maxEntries, boxWidth: screenWidth, isGamepadConnected: $isGamepadConnected)
                }
            } else if MangaBook.shared.layerVisibility == .displayConversationB {
                if let conversation = page.conversationB?.appendDoneIfNeeded() {
                    MangaConversationView(locationID: "Conversation", portrait: conversation.portrait, name: conversation.name, message: conversation.message, leftSide: conversation.leftSide, rightSide: conversation.rightSide, maxEntries: conversation.maxEntries, boxWidth: screenWidth, isGamepadConnected: $isGamepadConnected)
                }
            } else if MangaBook.shared.layerVisibility == .displayConversationResultA {
                if let conversation = page.conversationA {
                    MangaConversationResultView(locationID: "Conversation", actor: conversation.actor, portrait: conversation.portrait, name: conversation.name, result1: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult1), result2: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult2), result3: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult3), boxWidth: screenWidth, isGamepadConnected: $isGamepadConnected)
                }
            } else if MangaBook.shared.layerVisibility == .displayConversationResultB {
                if let conversation = page.conversationB {
                    MangaConversationResultView(locationID: "Conversation", actor: conversation.actor, portrait: conversation.portrait, name: conversation.name, result1: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult1), result2: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult2), result3: MangaWorks.expandMacros(in: MangaBook.shared.conversationResult3), boxWidth: screenWidth, isGamepadConnected: $isGamepadConnected)
                }
            }
            
            Image("HUDReticle")
                .resizable()
                .frame(width: 128, height: 128)
                .opacity(0.50)
                .allowsHitTesting(false)
            
            actionButtons()
            
            // Direction Indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    CompassView()
                        .frame(width: 50.0, height: 50.0)
                        .rotationEffect(Angle(degrees: Double(rotationIndicator)))
                }
            }
            .frame(width: screenWidth - 10, height: screenHeight + 20)
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth + zoomBuffer, height: MangaPageScreenMetrics.screenHeight + zoomBuffer)
        .clipped()
        //.padding(.horizontal)
    }
    
    @ViewBuilder func actionButtons() -> some View {
        // Action Buttons
        if let interaction = interaction {
            VStack {
                Spacer()
                
                if isGamepadConnected {
                    ZStack {
                        MangaIconButton(iconName: interaction.action.icon) {
                            handleInteraction(interaction: interaction)
                        }
                        
                        ScaledImageView(imageName: GamepadManager.gamepadOne.gampadInfo.buttonXImage, scale: 0.70)
                            .offset(x:50.0, y:50.0)
                    }
                } else {
                    MangaIconButton(iconName: interaction.action.icon) {
                        handleInteraction(interaction: interaction)
                    }
                }
                
                Spacer()
            }
        } else if showNavigationMarker {
            VStack {
                Spacer()
                
                if isGamepadConnected {
                    ZStack {
                        MangaIconButton(iconName: "arrow.up.circle.fill") {
                            handleNavigation()
                        }
                        
                        ScaledImageView(imageName: GamepadManager.gamepadOne.gampadInfo.buttonXImage, scale: 0.70)
                            .offset(x:50.0, y:50.0)
                    }
                } else {
                    MangaIconButton(iconName: "arrow.up.circle.fill") {
                        handleNavigation()
                    }
                }
                
                Spacer()
            }
        }
    }
    
    func handleNavigation() {
        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
        if let nextNavPoint {
            PanoramaManager.shouldUpdateImage = true
            PanoramaManager.shouldResetCameraAngle = false
            MangaBook.shared.displayPage(id: MangaWorks.expandMacros(in: nextNavPoint.tag))
            
            if nextNavPoint.soundEffect != "" {
                SoundManager.shared.playSoundEffect(sound: nextNavPoint.soundEffect, channel: .channel03)
            }
        }
        
        nextNavPoint = nil
    }
    
    func handleInteraction(interaction: MangaPageInteraction) {
        // Handle interaction
        SpeechManager.shared.stopSpeaking()
        switch interaction.action {
        case .use:
            SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
        default:
            SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
        }
        
        if interaction.notbookID != "" {
            MangaBook.shared.addNote(notebookID: interaction.notbookID, image: interaction.notebookImage, title: interaction.notebookTitle, entry: interaction.notebookEntry)
        }
        
        if interaction.soundEffect != "" {
            SoundManager.shared.playSoundEffect(path: interaction.soundEffect, channel: .channel03)
        }
        
        MangaWorks.runGraceScript(interaction.handler)
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
                    MangaBook.shared.displayPage(id: page.previousPage)
                }
                .padding(.leading)
            }
            
            Spacer()
            
            if page.nextPage != "" {
                MangaButton(title: "Next >", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
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
    MangaPanoramaView(page: MangaPage(id: "00", pageType: .panoramaPage, imageName: "PanoramaG04"))
}
