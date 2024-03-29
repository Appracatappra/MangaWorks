//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/5/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

/// `MangaCoverView` renders the cover view of a `MangaBook` using three layers of images to form the cover and a series of `MangaAction` items to represent menu items for the cover.
public struct MangaCoverView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - cover: A `MangaCover` object that defiens the look and feel of the cover and contains the `MangaAction` items to represent menu items for the cover.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(uniqueID: String = "Cover", cover: MangaCover, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.uniqueID = uniqueID
        self.cover = cover
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "Cover"
    
    /// A `MangaCover` object that defiens the look and feel of the cover and contains the `MangaAction` items to represent menu items for the cover.
    public var cover:MangaCover = MangaCover()
    
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
    
    /// Returns the header offset based on the device the app is running on.
    private var headerOffset:CGFloat {
        if HardwareInformation.isPhone {
            switch HardwareInformation.screenHeight {
            case 667:
                return 25
            default:
                return 100
            }
        } else {
            return 25
        }
    }
    
    /// Returns the menu offset based on the device the app is running on.
    private var menuOffset:CGFloat {
        if HardwareInformation.isPhone {
            switch HardwareInformation.screenHeight {
            case 667:
                return 25
            default:
                return 100
            }
        } else {
            return 100
        }
    }
    
    // MARK: - Computed Properties
    /// Gets the inset for the comic page.
    public var body: some View {
        ZStack {
            if HardwareInformation.isPhone {
                pageBodyContents()
            } else {
                MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: true, backgroundColor: cover.coverBackgroundColor) {
                    pageBodyContents()
                }
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
    @ViewBuilder func pageImageContents(imageName:String, fillMode:MangaCover.FillMode = .fit) -> some View {
        if cover.imageSource == .appBundle {
            switch fillMode {
            case .stretch:
                Image(imageName)
                    .resizable()
            case .fit:
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, headerOffset)
            case .fill:
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(.top, headerOffset)
            }
        } else if let image = MangaWorks.image(name: imageName, withExtension: "png") {
            switch fillMode {
            case .stretch:
                Image(uiImage: image)
                    .resizable()
            case .fit:
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, headerOffset)
            case .fill:
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(.top, headerOffset)
            }
        }
    }
    
    /// Creates the main body of the cover.
    /// - Returns: Returns a view representing the body of the cover.
    @ViewBuilder func pageBodyContents() -> some View {
        ZStack {
            // Cover Background image
            VStack {
                if cover.backgroundVerticalPlacement == .bottom {
                    Spacer()
                }
                
                pageImageContents(imageName: cover.coverBackgroundImage, fillMode: cover.backgroundFillMode)
                
                if cover.backgroundVerticalPlacement == .top {
                    Spacer()
                }
            }
            
            // Cover middle image
            VStack {
                if cover.middleVerticalPlacement == .bottom {
                    Spacer()
                }
                
                if HardwareInformation.isPhone {
                    pageImageContents(imageName: cover.coverMiddleImage, fillMode: cover.middleFillMode)
                        .padding(.top)
                } else {
                    pageImageContents(imageName: cover.coverMiddleImage, fillMode: cover.middleFillMode)
                }
                
                if cover.middleVerticalPlacement == .top {
                    Spacer()
                }
            }
            
            // Cover Menus
            VStack {
                Spacer()
                HStack (alignment: .center) {
                    // The left side menus.
                    if isGamepadConnected {
                        gamepadHelp()
                    } else {
                        leftMenu()
                    }
                    
                    Spacer()
                    
                    // The right side menus.
                    if isGamepadConnected {
                        GamepadMenuView(id: "MainMenu", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.stormfaze.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 6, boxWidth: 250, padding: 0)
                    } else {
                        rightMenu()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Cover top image
            VStack {
                if cover.foregroundVerticalPlacement == .bottom {
                    Spacer()
                }
                
                pageImageContents(imageName: cover.coverForegroundImage, fillMode: cover.foregroundFillMode)
                    .allowsHitTesting(false)
                
                if cover.foregroundVerticalPlacement == .top {
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    /// Creates the left side touch menu for the cover.
    /// - Returns: Returns a view containing the left side touch menu.
    @ViewBuilder func leftMenu() -> some View {
        VStack(alignment: .leading) {
            ForEach(cover.leftSide) {action in
                if MangaWorks.evaluateCondition(action.condition) {
                    MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                        MangaWorks.runGraceScript(action.excute)
                    }
                    .padding(.bottom, menuPadding)
                }
            }
        }
    }
    
    /// Creates the right side touch menu for the cover.
    /// - Returns: Returns a view containing the right side touch menu.
    @ViewBuilder func rightMenu() -> some View {
        VStack(alignment: .trailing) {
            ForEach(cover.rightSide) {action in
                if MangaWorks.evaluateCondition(action.condition) {
                    MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                        MangaWorks.runGraceScript(action.excute)
                    }
                    .padding(.bottom, menuPadding)
                }
            }
        }
    }
    
    /// Creates the menu for an attached gamepad.
    /// - Returns: Returns a `GamepadMenu` containing all of the menu items.
    func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu()
        
        for action in cover.leftSide {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text) {
                    MangaWorks.runGraceScript(action.excute)
                }
            }
        }
        
        for action in cover.rightSide {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text) {
                    MangaWorks.runGraceScript(action.excute)
                }
            }
        }
        
        return menu
    }
    
    /// Creates the help buttons to display when a gamepad is attached to the device the app is running on.
    /// - Returns: Returns a view containing the help items.
    @ViewBuilder func gamepadHelp() -> some View {
        VStack(alignment: .leading) {
            GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonAImage, title: "Help", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: MangaWorks.actionForegroundColor)
            
            if isAttachedToGameCenter {
                GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: "Game Center", scale: MangaPageScreenMetrics.controlButtonScale, enabledColor: MangaWorks.actionForegroundColor)
            }
        }
    }
}

#Preview {
    MangaCoverView(cover: MangaCover(imageSource: .packageBundle, coverBackgroundImage: "CoverBackground", coverMiddleImage: "CoverBackgroundBarcode", coverForegroundImage: "ReedWrightCover"))
}
