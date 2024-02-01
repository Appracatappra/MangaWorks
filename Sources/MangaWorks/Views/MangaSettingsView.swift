//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/11/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

public struct MangaSettingsView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - entries: A collection of `MangaPageAction` objects to display.
    ///   - backgroundColor: The background color of the page.
    ///   - backgroundImage: The background image to display behind the menu.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID: String = "AppSettings", entries: [MangaPageAction] = [], backgroundColor: Color = MangaWorks.menuBackgroundColor, backgroundImage: String = "", isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.uniqueID = uniqueID
        self.entries = entries
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "AppSettings"
    
    /// A collection of `MangaPageAction` objects to display.
    public var entries:[MangaPageAction] = []
    
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
    
    /// Holds a  UUID to force the view to refresh.
    @State private var refreshKey:String = ""
    
    //MARK: - Computed Properties
    var settings:[MangaPageAction] {
        var settings:[MangaPageAction] = []
        
        // Add generic settings
        settings.append(MangaPageAction(id: 1, text: "Play Background Music: @getPreferenceState('playBackgroundMusic')", excute: "call @flipPreference('playBackgroundMusic')"))
        
        settings.append(MangaPageAction(id: 2, text: "Play Background Sounds: @getPreferenceState('playBackgroundSounds')", excute: "call @flipPreference('playBackgroundSounds')"))
        
        settings.append(MangaPageAction(id: 3, text: "Play Sound Effects: @getPreferenceState('playSoundEffects')", excute: "call @flipPreference('playSoundEffects')"))
        
        settings.append(MangaPageAction(id: 4, text: "Auto Read Page Text: @getPreferenceState('autoReadPage')", excute: "call @flipPreference('autoReadPage')"))
        
        settings.append(MangaPageAction(id: 5, text: "Read Text When Tapped: @getPreferenceState('readOnTap')", excute: "call @flipPreference('readOnTap')"))
        
        settings.append(MangaPageAction(id: 6, text: "Expand Text When Tapped: @getPreferenceState('expandOnTap')", excute: "call @flipPreference('expandOnTap')"))
        
        settings.append(MangaPageAction(id: 7, text: "Show Full Page Viewer Quicktips: @getPreferenceState('showFullPageQuicktip')", excute: "call @flipPreference('showFullPageQuicktip')"))
        
        settings.append(MangaPageAction(id: 8, text: "Show Panels Viewer Quicktips: @getPreferenceState('showPanelsQuicktip')", excute: "call @flipPreference('showPanelsQuicktip')"))
        
        settings.append(MangaPageAction(id: 9, text: "Show Panorama Viewer Quicktips: @getPreferenceState('showPanoQuicktip')", excute: "call @flipPreference('showPanoQuicktip')"))
        
        // Add app specific settings
        for entry in entries {
            settings.append(entry)
        }
        
        return settings
    }
    
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
            return CGFloat(100.0)
        } else {
            return CGFloat(90.0)
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
    
    /// Returns the menu padding based on the device the app is running on.
    private var menuPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 5
        } else {
            return 5
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, backgroundColor: backgroundColor) {
                pageBodyContents(screenOrientation: screenOrientation, refreshKey: refreshKey)
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
                buttonBUsage(viewID: uniqueID, "Close **Settings Menu**.")
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
    @ViewBuilder func pageBodyContents(screenOrientation:UIDeviceOrientation, refreshKey:String) -> some View {
        ZStack {
            if backgroundImage != "" {
                Image(backgroundImage)
                    .resizable()
                    .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
            }
            
            VStack {
                Text(markdown: "Settings")
                    .font(ComicFonts.Troika.ofSize(48))
                    .foregroundColor(MangaWorks.actionFontColor)
                    .padding(.top)
                
                // The right side menus.
                if isGamepadConnected {
                    GamepadMenuView(id: "SettingItems", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.Komika.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 8, boxWidth: cardWidth, padding: 0)
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
            MangaButton(title: "Back", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                MangaBook.shared.changeView(viewID: "[COVER]")
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
            GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: "Back", scale: MangaPageScreenMetrics.controlButtonScale)
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
                Text(" ")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            ZStack {
                Text(" ")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.trailing)
            }
            .frame(width: footerColumnWidth)
        }
        .padding(.bottom, footerPadding)
    }
    
    /// Force the view to repaint itself.
    private func refreshView() {
        refreshKey = UUID().uuidString
    }
    
    /// Creates the right side touch menu for the cover.
    /// - Returns: Returns a view containing the right side touch menu.
    @ViewBuilder func touchMenu() -> some View {
        ScrollView {
            VStack {
                ForEach(settings) {action in
                    if MangaWorks.evaluateCondition(action.condition) {
                        MangaButton(title: MangaWorks.expandMacros(in: action.text), font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                            MangaWorks.runGraceScript(action.excute)
                            refreshView()
                        }
                        .padding(.bottom, menuPadding)
                    }
                }
            }
        }
    }
    
    /// Creates the menu for an attached gamepad.
    /// - Returns: Returns a `GamepadMenu` containing all of the menu items.
    private func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu()
        
        for action in settings {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: MangaWorks.expandMacros(in: action.text)) {
                    MangaWorks.runGraceScript(action.excute)
                    refreshView()
                }
            }
        }
        
        return menu
    }
}

#Preview {
    MangaSettingsView()
}
