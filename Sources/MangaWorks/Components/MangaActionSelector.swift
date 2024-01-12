//
//  HUDView.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 3/10/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SoundManager
import SpeechManager

/// Displays a UI for the user to be able to select an action from a selection of actions.
public struct MangaActionSelector: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - avatarImage: The avatar imageg to displsy in the input box.
    ///   - backgroundImage: The background image to display in the input box.
    ///   - locationID: The Unique ID of the location this controls is being displayed for.
    ///   - title: The title of the entry.
    ///   - leftSide: The actions to display on the left side of the entry.
    ///   - rightSide: The actions to display on the right side of the entry.
    ///   - font: The font to display the entry in.
    ///   - fontColor: The font color.
    ///   - menuGradient: The menu item gradient.
    ///   - menuSelectedGradient: The menu item selected gradient.
    ///   - maxEntries: The maximum number of menu items to display.
    ///   - boxWidth: The input control width.
    ///   - boxHeight: The input control height.
    ///   - isGamepadConnected: If `true` a gamepad is connected.
    public init(avatarImage: String = MangaWorks.inputAvatarImage, backgroundImage: String = MangaWorks.inputBackgroundImage, locationID: String = "", title: String = "", leftSide: [MangaPageAction] = [], rightSide: [MangaPageAction] = [], font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.controlForegroundColor, menuGradient: [Color] = MangaWorks.menuGradient, menuSelectedGradient: [Color] = MangaWorks.menuSelectedGradient, maxEntries: Int = 2, boxWidth: CGFloat = MangaPageScreenMetrics.screenHalfWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, isGamepadConnected: Binding<Bool>) {
        self.avatarImage = avatarImage
        self.backgroundImage = backgroundImage
        self.locationID = locationID
        self.title = title
        self.leftSide = leftSide
        self.rightSide = rightSide
        self.font = font
        self.fontColor = fontColor
        self.menuGradient = menuGradient
        self.menuSelectedGradient = menuSelectedGradient
        self.maxEntries = maxEntries
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self._isGamepadConnected = isGamepadConnected
    }
    
    // MARK: - Properties
    /// The avatar imageg to displsy in the input box.
    public var avatarImage:String = MangaWorks.inputAvatarImage
    
    /// The background image to display in the input box.
    public var backgroundImage:String = MangaWorks.inputBackgroundImage
    
    /// The Unique ID of the location this controls is being displayed for.
    public var locationID:String = ""
    
    /// The title of the entry.
    public var title:String = ""
    
    /// The actions to display on the left side of the entry.
    public var leftSide:[MangaPageAction] = []
    
    /// The actions to display on the right side of the entry.
    public var rightSide:[MangaPageAction] = []
    
    /// The font to display the entry in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// The menu item gradient.
    public var menuGradient:[Color] = MangaWorks.menuGradient
    
    /// The menu item selected gradient.
    public var menuSelectedGradient:[Color] = MangaWorks.menuSelectedGradient
    
    /// The maximum number of menu items to display.
    public var maxEntries:Int = 2
    
    /// The input control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth
    
    /// The input control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    // MARK: - Bindings
    /// If `true` a gamepad is connected.
    @Binding public var isGamepadConnected:Bool
    
    // MARK: - Computed Properties
    /// The vertical padding based on the device.
    private var paddingVertical:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 60.0
        }
    }
    
    /// The horizontal padding based on the device.
    private var paddingHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 20.0
        }
    }
    
    /// The menu item width based on the device.
    private var gamepadMenuItemWidth:Float {
        if HardwareInformation.isPhone {
            return 300
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 300
            default:
                return 500
            }
        } else {
            return 500
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .top) {
                if isGamepadConnected {
                    gamepadContent()
                } else {
                    if HardwareInformation.isPhone {
                        iPhoneContent()
                    } else {
                        iPadContent()
                    }
                }
            }
            .frame(width: boxWidth, height: boxHeight, alignment: .center)
            .clipped()
        }
    }
    
    // MARK: - Functions
    /// Creates a gamepad menu of the actions.
    /// - Returns: Returns a gamepad menu of the available actions.
    private func buildMenu() -> GamepadMenu {
        let menu = GamepadMenu(style: .cards)
        
        for item in leftSide {
            menu.addItem(title: MangaWorks.expandMacros(in: item.text), enabled: MangaWorks.evaluateCondition(item.condition)) {
                Execute.onMain {
                    SpeechManager.shared.stopSpeaking()
                    SoundManager.shared.playSoundEffect(sound: "Click_Electronic_06.mp3")
                    MangaWorks.runGraceScript(item.excute)
                }
            }
        }
        
        for item in rightSide {
            menu.addItem(title: MangaWorks.expandMacros(in: item.text), enabled: MangaWorks.evaluateCondition(item.condition)) {
                Execute.onMain {
                    SpeechManager.shared.stopSpeaking()
                    SoundManager.shared.playSoundEffect(sound: "Click_Electronic_06.mp3")
                    MangaWorks.runGraceScript(item.excute)
                }
            }
        }
        
        return menu
    }
    
    /// Draws the gamepad contents.
    /// - Returns: Returns a view with the gamepad contents.
    @ViewBuilder private func gamepadContent() -> some View {
        if let sourceImage = UIImage.asset(named: backgroundImage, atScale: 1.0) {
            Image(uiImage: sourceImage)
                .resizable()
                .frame(width: boxWidth, height: boxHeight)
        }
        
        HStack {
            if HardwareInformation.isPhone {
                if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.2) {
                    Image(uiImage: sourceImage)
                    
                }
            } else {
                if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.3) {
                    Image(uiImage: sourceImage)
                        .resizable()
                        .scaledToFit()
                    
                }
            }
            
            VStack {
                Text(markdown: MangaWorks.expandMacros(in: title))
                    .font(font)
                    .foregroundColor(fontColor)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                    .shadow(radius: 5.0)
                
                GamepadMenuView(id: "HUD-\(locationID)", menu: buildMenu(), fontSize: 24, gradientColors: menuGradient, selectedColors: menuSelectedGradient, maxEntries: maxEntries, boxWidth: gamepadMenuItemWidth, padding: 5.0)
                
                Spacer()
            }
        }
        .frame(width: boxWidth, height: boxHeight)
    }
    
    /// Draws the iPhone contents.
    /// - Returns: Returns a view with the iPhone contents.
    @ViewBuilder private func iPhoneContent() -> some View {
        if let sourceImage = UIImage.asset(named: backgroundImage, atScale: 1.0) {
            Image(uiImage: sourceImage)
                .resizable()
                .frame(width: boxWidth, height: boxHeight)
        }
        
        HStack {
            if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.2) {
                Image(uiImage: sourceImage)
                    
            }
            
            VStack {
                Text(markdown: MangaWorks.expandMacros(in: title))
                    .font(font)
                    .foregroundColor(fontColor)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                .shadow(radius: 5.0)
                
                ScrollView {
                    VStack {
                        ForEach(leftSide) {action in
                            if MangaWorks.evaluateCondition(action.condition) {
                                action.view
                            }
                        }
                        
                        ForEach(rightSide) {action in
                            if MangaWorks.evaluateCondition(action.condition) {
                                action.view
                            }
                        }
                    }
                    .padding(.bottom, 200)
                }
            }
        }
        .frame(width: boxWidth, height: boxHeight)
    }
    
    /// Draws the iPad contents.
    /// - Returns: Returns a view containing the iPad contents.
    @ViewBuilder private func iPadContent() -> some View {
        if let sourceImage = UIImage.asset(named: backgroundImage, atScale: 1.0) {
            Image(uiImage: sourceImage)
                .resizable()
                .frame(width: boxWidth, height: boxHeight)
        }
        
        if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.3) {
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
                
        }
        
        HStack {
            VStack {
                Text(markdown: MangaWorks.expandMacros(in: title))
                    .font(font)
                    .foregroundColor(fontColor)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                    .shadow(radius: 5.0)
                
                ScrollView {
                    VStack {
                        ForEach(leftSide) {action in
                            if MangaWorks.evaluateCondition(action.condition) {
                                action.view
                            }
                        }
                    }
                    .padding(.bottom, 200)
                }
            }
            
            Spacer()
            
            VStack {
                // HACK: Ensure the spacing is the same from the left side to the right side.
                Text(markdown: "X")
                    .font(font)
                    .foregroundColor(Color.clear)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                    .shadow(radius: 5.0)
                
                ScrollView {
                    VStack {
                        ForEach(rightSide) {action in
                            if MangaWorks.evaluateCondition(action.condition) {
                                action.view
                            }
                        }
                    }
                    .padding(.bottom, 200)
                }
            }
        }
    }
}

#Preview {
    MangaActionSelector(title: "Hello World:", isGamepadConnected: .constant(false))
}
