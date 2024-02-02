//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 2/2/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

public struct MangaHintsView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - backgroundColor: The background color of the page.
    ///   - backgroundImage: The background image to display behind the menu.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID:String = "HintsView", backgroundColor: Color = MangaWorks.menuBackgroundColor, backgroundImage:String = "", isGamepadRequired:Bool = false, isAttachedToGameCenter:Bool = false) {
        self.uniqueID = uniqueID
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "HintsView"
    
    /// The background color of the page.
    public var backgroundColor: Color = MangaWorks.menuBackgroundColor
    
    /// The background image to display behind the menu.
    public var backgroundImage:String = ""
    
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
    
    /// Tracks the current level of hints that have been revealed.
    @State private var index:Int = 0
    
    // MARK: - Computed Properties
    /// Returns the size of the footer text.
    private var footerTextSize:Float {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 12
        }
    }
    
    /// Returns the menu padding based on the device the app is running on.
    private var menuPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 5
        } else {
            return 5
        }
    }
    
    /// Returns the menu font size based on the device the app is running on.
    private var menuSize:Float {
        switch HardwareInformation.screenWidth {
        case 744:
            return 27
        case 1024:
            return 42
        default:
            if HardwareInformation.isPhone {
                return 18
            } else if HardwareInformation.isPad {
                switch HardwareInformation.deviceOrientation {
                case .landscapeLeft, .landscapeRight:
                    return 28
                default:
                    return 34
                }
            } else {
                return 34
            }
        }
    }
    
    private var textSize:Float {
        switch HardwareInformation.screenWidth {
        case 744:
            return 18
        case 1024:
            return 18
        default:
            //Debug.log(">>>> Screen Width: \(HardwareInformation.screenWidth)")
            if HardwareInformation.isPhone {
                return 16
            } else if HardwareInformation.isPad {
                switch HardwareInformation.deviceOrientation {
                case .landscapeLeft, .landscapeRight:
                    return 16
                default:
                    return 18
                }
            } else {
                return 18
            }
        }
    }
    
    /// The card width.
    private var cardWidth:Float {
        return Float(HardwareInformation.screenHalfWidth - 100)
    }
    
    /// Gets the width of a footer column.
    private var footerColumnWidth:CGFloat {
        return MangaPageScreenMetrics.screenHalfWidth / 3.0
    }
    
    /// Gets the inset for the comic page.
    private var insetHorizontal:CGFloat {
        switch HardwareInformation.screenWidth {
        case 375:
            return CGFloat(80.0)
        default:
            if HardwareInformation.isPhone {
                return CGFloat(50.0)
            } else {
                return CGFloat(90.0)
            }
        }
    }
    
    /// Gets the inset for the comic page.
    private var insetVertical:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(100.0)
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
    
    var hintPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 20
        } else {
            return 50
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, backgroundColor: backgroundColor) {
                pageBodyContents(screenOrientation: screenOrientation)
            }
            #if os(iOS)
            .statusBar(hidden: true)
            #endif
            
            // Display the header and footer overlay.
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
                buttonBUsage(viewID: uniqueID, "Close **Hint Menu**.")
                buttonXUsage(viewID: uniqueID, "Reveal Hint.")
            })
            
            let tag = MangaBook.shared.currentPage.hintTag
            index = MangaBook.shared.getStateInt(key: tag)
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
                MangaBook.shared.changeView(viewID: "[COVER]")
            }
        }
        .onGamepadButtonX(viewID: uniqueID) { isPressed in
            if isPressed {
                revealNextHint()
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
    /// Reveals the next available hint.
    private func revealNextHint() {
        
        if index < (MangaBook.shared.currentPage.hints.count - 1) {
            let hint = MangaBook.shared.currentPage.hints[index]
            
            if hint.beforeReveal != "" {
                if !MangaWorks.evaluateCondition(hint.beforeReveal) {
                    return
                }
            }
            
            if hint.pointCost > 0 {
                var points = MangaBook.shared.getStateInt(key: "Points")
                points -= hint.pointCost
                MangaBook.shared.setStateInt(key: "Points", value: points)
            }
            
            // Adjust index
            index += 1
            let tag = MangaBook.shared.currentPage.hintTag
            MangaBook.shared.setStateInt(key: tag, value: index)
            MangaBook.shared.requestSaveState()
            
            if hint.onReveal != "" {
                MangaWorks.runGraceScript(hint.onReveal)
            }
        }
    }
    
    /// Draws the body of the menu.
    /// - Returns: Returns a view with the body of the menu.
    @ViewBuilder func pageBodyContents(screenOrientation:UIDeviceOrientation) -> some View {
        ZStack {
            if backgroundImage != "" {
                Image(backgroundImage)
                    .resizable()
                    .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
            }
            
            VStack {
                Text(markdown: "Hints")
                    .font(ComicFonts.Troika.ofSize(48))
                    .foregroundColor(.white)
                    .padding(.top)
                
                ScrollView {
                    VStack {
                        ForEach(MangaBook.shared.currentPage.hints) { hint in
                            if hint.id <= index {
                                Text(markdown: "\(hint.id + 1)) \(MangaWorks.expandMacros(in: hint.text))")
                                    .font(ComicFonts.Komika.ofSize(32))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, hintPadding)
                            }
                        }
                        
                        Text(markdown: "Hint \(index + 1) of \(MangaBook.shared.currentPage.hints.count)")
                            .font(ComicFonts.Komika.ofSize(18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, hintPadding)
                    }
                }
                .frame(width: MangaPageScreenMetrics.screenWidth - insetHorizontal)
                
                // The right side menus.
                if isGamepadConnected {
                    HStack {
                        GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonAImage, title: "Close", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: .white)
                        
                        if index < (MangaBook.shared.currentPage.hints.count - 1) {
                            GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: "Next Hint", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: .white)
                        }
                    }
                } else {
                    if index < (MangaBook.shared.currentPage.hints.count - 1) {
                        IconButton(icon: "rectangle.stack.badge.play.fill", text: "Reveal Next Hint") {
                            revealNextHint()
                        }
                    }
                }
                
                if index < (MangaBook.shared.currentPage.hints.count - 1) {
                    let nextIndex = index + 1
                    let hint = MangaBook.shared.currentPage.hints[nextIndex]
                    
                    Text(markdown: "Next Hint Costs: \(hint.pointCost) Points")
                        .font(ComicFonts.Komika.ofSize(24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical - 50.0)
        }
        .ignoresSafeArea()
    }
    
    /// Draws the header and footer overlay contents.
    /// - Returns: Returns a view containing the header and footer.
    @ViewBuilder func pageOverlayContents() -> some View {
        VStack {
            if isGamepadConnected {
                pageheaderGamepad()
            } else {
                pageheader()
            }
            
            Spacer()
            
            pageFooter()
        }
    }
    
    /// Draws the page header.
    /// - Returns: Returns a view containing the page header.
    @ViewBuilder func pageheader() -> some View {
        HStack {
            MangaButton(title: "Close", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                MangaBook.shared.changeView(viewID: "[CURRENT]")
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding(.top, headerPadding)
    }
    
    /// Renders the page header when a gamepdais attached.
    /// - Returns: Returs a view containing the gamepad header.
    @ViewBuilder func pageheaderGamepad() -> some View {
        HStack {
            GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: "Close", scale: MangaPageScreenMetrics.controlButtonScale)
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
                Text("Hints")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            ZStack {
                Text("")
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
    MangaHintsView()
}
