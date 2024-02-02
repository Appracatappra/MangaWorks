//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/10/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

// MARK: - Computed Properties
/// Gets the inset for the comic page.
public struct MangaActionMenuView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - backgroundColor: The background color of the page.
    ///   - backgroundImage: The background image to display behind the menu.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID: String = "ActionMenu", backgroundColor: Color = MangaWorks.menuBackgroundColor, backgroundImage:String = "", isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.uniqueID = uniqueID
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "ActionMenu"
    
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
            return 0
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
        if HardwareInformation.isPhone {
            return CGFloat(40.0)
        } else {
            return CGFloat(90.0)
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
                buttonBUsage(viewID: uniqueID, "Close **Action Menu**.")
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
                MangaBook.shared.returnToLastView()
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
                Text(markdown: "Actions")
                    .font(ComicFonts.Troika.ofSize(48))
                    .foregroundColor(MangaWorks.actionFontColor)
                    .padding(.top)
                
                // The right side menus.
                if isGamepadConnected {
                    GamepadMenuView(id: "ActionItems", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.Komika.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 8, boxWidth: cardWidth, padding: 0)
                } else {
                    touchMenu()
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
                MangaBook.shared.returnToLastView()
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
                Text("Action Menu")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            ZStack {
                Text("Page: \(MangaBook.shared.currentPage.id)")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.trailing)
            }
            .frame(width: footerColumnWidth)
        }
        .padding(.bottom, footerPadding)
    }
    
    /// Creates the right side touch menu for the cover.
    /// - Returns: Returns a view containing the right side touch menu.
    @ViewBuilder func touchMenu() -> some View {
        ScrollView {
            VStack {
                ForEach(MangaBook.shared.actionMenuItems) {action in
                    if MangaWorks.evaluateCondition(action.condition) {
                        MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                            MangaWorks.runGraceScript(action.excute)
                        }
                        .frame(width: MangaPageScreenMetrics.screenWidth - insetHorizontal)
                        .padding(.bottom, menuPadding)
                    }
                }
            }
        }
    }
    
    /// Creates the menu for an attached gamepad.
    /// - Returns: Returns a `GamepadMenu` containing all of the menu items.
    func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu()
        
        for action in MangaBook.shared.actionMenuItems {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text) {
                    MangaWorks.runGraceScript(action.excute)
                }
            }
        }
        
        return menu
    }
}

#Preview {
    MangaActionMenuView()
}
