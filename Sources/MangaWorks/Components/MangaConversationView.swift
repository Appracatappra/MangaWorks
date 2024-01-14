//
//  ConversationView.swift
//  ReedWriteCycle
//
//  Created by Kevin Mullins on 2/26/23.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SoundManager
import SpeechManager

/// Displays a n inline conversation in the Manga's UI.
public struct MangaConversationView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - locationID: The unique location ID.
    ///   - portrait: The character portrait to display.
    ///   - name: The character name.
    ///   - message: The question being asked.
    ///   - leftSide: The left side actions.
    ///   - rightSide: The right side actions.
    ///   - font: The font to display the conversation in.
    ///   - fontColor: The font color.
    ///   - menuGradient: The menu item gradient color.
    ///   - menuSelectedGradient: The selected menu item gradient color.
    ///   - maxEntries: The number of menu entries to display.
    ///   - boxWidth: The control width.
    ///   - boxHeight: The control height.
    ///   - topBoxHeight: The control top height.
    ///   - isGamepadConnected: If `true`, a gamepad is connected.
    public init(locationID: String = "", portrait: String = "", name: String = "", message: String = "", leftSide: [MangaPageAction] = [], rightSide: [MangaPageAction] = [], font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.conversationForegroundColor, menuGradient: [Color] = MangaWorks.menuGradient, menuSelectedGradient: [Color] = MangaWorks.menuSelectedGradient, maxEntries: Int = 2, boxWidth: CGFloat = MangaPageScreenMetrics.screenWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, topBoxHeight: CGFloat  = UIScreen.main.bounds.height / CGFloat(4.0), isGamepadConnected: Binding<Bool>) {
        self.locationID = locationID
        self.portrait = portrait
        self.name = name
        self.message = message
        self.leftSide = leftSide
        self.rightSide = rightSide
        self.font = font
        self.fontColor = fontColor
        self.menuGradient = menuGradient
        self.menuSelectedGradient = menuSelectedGradient
        self.maxEntries = maxEntries
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.topBoxHeight = topBoxHeight
        self._isGamepadConnected = isGamepadConnected
    }
    
    // MARK: - Properties
    /// The unique location ID.
    public var locationID:String = ""
    
    /// The character portrait to display.
    public var portrait:String = ""
    
    /// The character name.
    public var name:String = ""
    
    /// The question being asked.
    public var message:String = "What action do you want to take?"
    
    /// The left side actions.
    public var leftSide:[MangaPageAction] = []
    
    /// The right side actions.
    public var rightSide:[MangaPageAction] = []
    
    /// The font to display the conversation in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.conversationForegroundColor
    
    /// The menu item gradient color.
    public var menuGradient:[Color] = MangaWorks.menuGradient
    
    /// The selected menu item gradient color.
    public var menuSelectedGradient:[Color] = MangaWorks.menuSelectedGradient
    
    /// The number of menu entries to display.
    public var maxEntries:Int = 2
    
    /// The control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenWidth
    
    /// The control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The control top height.
    public var topBoxHeight:CGFloat = UIScreen.main.bounds.height / CGFloat(4.0)
    
    // MARK: - States
    /// If `true`, a gamepad is connected.
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
    
    /// The protrait scale based on the device.
    private var portraitScale:CGFloat {
        switch HardwareInformation.deviceOrientation {
        case .unknown:
            // HACK: The orientation is always reported as "unknown" as first draw, this code will handle that situation.
            if HardwareInformation.screenWidth > HardwareInformation.screenHeight {
                return 0.7
            } else {
                return 1.0
            }
        case .landscapeLeft,.landscapeRight:
            return 0.7
        default:
            return 1.0
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
    /// Builds the gamepad menu.
    /// - Returns: Returns a menu containing all of the action items.
    private func buildMenu() -> GamepadMenu {
        let menu = GamepadMenu(style: .cards)
        
        for item in leftSide {
            menu.addItem(title: MangaWorks.expandMacros(in: item.text), enabled: MangaWorks.evaluateCondition(item.condition)) {
                Execute.onMain {
                    SpeechManager.shared.stopSpeaking()
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
                    MangaWorks.runGraceScript(item.excute)
                }
            }
        }
        
        for item in rightSide {
            menu.addItem(title: MangaWorks.expandMacros(in: item.text), enabled: MangaWorks.evaluateCondition(item.condition)) {
                Execute.onMain {
                    SpeechManager.shared.stopSpeaking()
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
                    MangaWorks.runGraceScript(item.excute)
                }
            }
        }
        
        return menu
    }
    
    /// Creates the gamepad contents.
    /// - Returns: Returns a view containing the gamepad contents.
    @ViewBuilder private func gamepadContent() -> some View {
        
        VStack {
            MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaWorks.expandMacros(in: message), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            
            HStack{
                GamepadMenuView(id: "Conv\(locationID)", menu: buildMenu(), fontSize: 24, gradientColors: menuGradient, selectedColors: menuSelectedGradient, maxEntries: maxEntries, boxWidth: gamepadMenuItemWidth, padding: 5.0)
                
                Spacer()
            }
            .padding(.horizontal, (HardwareInformation.isPhone) ? 5 : 10)
        }
        
        HStack {
            Spacer()
            
            if HardwareInformation.isPhone {
                if let sourceImage = UIImage.asset(named: portrait, atScale: 0.6) {
                    Image(uiImage: sourceImage)
                        .allowsHitTesting(false)
                }
            } else {
                if let sourceImage = UIImage.asset(named: portrait, atScale: portraitScale) {
                    Image(uiImage: sourceImage)
                        .allowsHitTesting(false)
                        .shadow(color: .black, radius: 10)
                }
            }
        }
        .frame(width: boxWidth, height: boxHeight)
    }
    
    /// Creates the iPhone contents.
    /// - Returns: Returns a view with the iPhone contents.
    @ViewBuilder private func iPhoneContent() -> some View {
        VStack {
            MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaWorks.expandMacros(in: message), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            
            HStack{
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
                }
                .frame(height: boxHeight - topBoxHeight - 25)
                
                Spacer()
            }
            .padding(.horizontal, 5)
        }
        
        HStack {
            Spacer()
            
            if let sourceImage = UIImage.asset(named: portrait, atScale: 0.6) {
                Image(uiImage: sourceImage)
                    .allowsHitTesting(false)
                    .shadow(color: .black, radius: 10)
            }
        }
        .frame(width: boxWidth, height: boxHeight)
    }
    
    /// Creates the iPad contents.
    /// - Returns: Returns a view with the iPad contents.
    @ViewBuilder private func iPadContent() -> some View {
        VStack {
            MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaWorks.expandMacros(in: message), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            
            HStack{
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
                }
               .frame(height: boxHeight - topBoxHeight)
                
                Spacer()
            }
            .padding(.horizontal, 50)
        }
        
        HStack {
            Spacer()
            
            if let sourceImage = UIImage.asset(named: portrait, atScale: portraitScale) {
                Image(uiImage: sourceImage)
                    .allowsHitTesting(false)
                    .shadow(color: .black, radius: 10)
            }
        }
        .frame(width: boxWidth, height: boxHeight)
    }
}

#Preview {
    MangaConversationView( isGamepadConnected: .constant(false))
}
