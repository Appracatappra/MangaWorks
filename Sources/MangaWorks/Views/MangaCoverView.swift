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

public struct MangaCoverView: View {
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "Cover"
    
    public var cover:MangaCover = MangaCover(imageSource: .packageBundle, coverBackgroundImage: "CoverBackground", coverMiddleImage: "CoverBackgroundBarcode", coverForegroundImage: "ReedWrightCover")
        .addAction(to: .left, text: "About")
        .addAction(to: .left, text: "Tips & Hints")
        .addAction(to: .left, text: "Settings")
        .addAction(to: .right, text: "Continue")
        .addAction(to: .right, text: "New Game")
        .addAction(to: .right, text: "Cyber Store")
        .addAction(to: .right, text: "Save Game")
        .addAction(to: .right, text: "Load Game")
    
    /// If `true`, a gamepad is required to run the app.
    public var isGamepadRequired:Bool = false
    
    @State private var showGamepadHelp:Bool = false
    @State private var isGamepadConnected:Bool = false
    
    // MARK: - Computed Properties
    private var menuPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 5
        } else {
            return 0
        }
    }
    
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
    
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: true) {
                pageBodyContents()
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
            // Cover Background
            VStack {
                if cover.imageSource == .appBundle {
                    Image(cover.coverBackgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, headerOffset)
                } else if let image = MangaWorks.image(name: cover.coverBackgroundImage, withExtension: "png") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, headerOffset)
                }
                
                Spacer()
            }
            
            // Cover middle
            VStack {
                Spacer()
                
                if cover.imageSource == .appBundle {
                    Image(cover.coverMiddleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let image = MangaWorks.image(name: cover.coverMiddleImage, withExtension: "png") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            
            // Cover Menus
            VStack {
                Spacer()
                
                HStack (alignment: .center) {
                    if isGamepadConnected {
                        
                    } else {
                        leftMenu()
                    }
                    
                    Spacer()
                    
                    if isGamepadConnected {
                        GamepadMenuView(id: "MainMenu", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.stormfaze.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 6, boxWidth: 250, padding: 0)
                    } else {
                        rightMenu()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Cover middle
            VStack {
                Spacer()
                
                if cover.imageSource == .appBundle {
                    Image(cover.coverForegroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .allowsHitTesting(false)
                } else if let image = MangaWorks.image(name: cover.coverForegroundImage, withExtension: "png") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    @ViewBuilder func leftMenu() -> some View {
        VStack(alignment: .leading) {
            ForEach(cover.leftSide) {action in
                if MangaWorks.evaluateCondition(action.condition) {
                    MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: false) {
                        // Execute Script here.
                    }
                    .padding(.bottom, menuPadding)
                }
            }
        }
    }
    
    @ViewBuilder func rightMenu() -> some View {
        VStack(alignment: .trailing) {
            ForEach(cover.rightSide) {action in
                if MangaWorks.evaluateCondition(action.condition) {
                    MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: false) {
                        // Execute Script here.
                    }
                    .padding(.bottom, menuPadding)
                }
            }
        }
    }
    
    func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu()
        
        for action in cover.leftSide {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text)
            }
        }
        
        for action in cover.rightSide {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text)
            }
        }
        
        return menu
    }
}

#Preview {
    MangaCoverView()
}
