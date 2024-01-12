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

/// Displays the result of an inline Manga conversation.
public struct MangaConversationResultView: View {
    
    // MARK: - Initializers
    
    // MARK: - Properties
    /// The unique id of the location.
    public var locationID:String = "ConResult"
    
    /// The voice to read the text in.
    public var actor:MangaVoiceActors = .narrator
    
    /// The character's portrait.
    public var portrait:String = ""
    
    /// The name of the character that you are talking to.
    public var name:String = ""
    
    /// The first result text.
    public var result1:String = ""
    
    /// The second result text.
    public var result2:String = ""
    
    /// The third result text.
    public var result3:String = ""
    
    /// The font to display the results in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.conversationForegroundColor
    
    /// The menu item gradient color.
    public var menuGradient:[Color] = MangaWorks.menuGradient
    
    /// The selected menu ite mgradient color.
    public var menuSelectedGradient:[Color] = MangaWorks.menuSelectedGradient
    
    /// The maximum menu entries to display.
    public var maxEntries:Int = 2
    
    /// The control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenWidth
    
    /// The control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The control top height.
    public var topBoxHeight:CGFloat = UIScreen.main.bounds.height / CGFloat(4.0)
    
    // MARK: - States
    /// If `true` a gamepad is connected.
    @Binding public var isGamepadConnected:Bool
    
    /// The entry currently being displayed.
    @State private var entry:Int = 1
    
    // MARK: - Computed Properties
    /// The button function.
    private var function:String {
        if result2 == "" && result3 == "" {
            return "OK"
        } else if result3 == "" {
            if entry == 2 {
                return "OK"
            }
        } else {
            if entry == 3 {
                return "OK"
            }
        }
        
        return "Next"
    }
    
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
    
    /// The menu item width.
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
    
    /// The protrait scale based on device.
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
    /// - Returns: Returns the gamepda menu.
    private func buildMenu() -> GamepadMenu {
        let menu = GamepadMenu(style: .cards)
        
        menu.addItem(title: function) {
            if function == "OK" {
                MangaBook.shared.changeLayerVisibility(visibility: .displayNothing)
            } else {
                entry += 1
            }
        }
        
        return menu
    }
    
    /// Creates the gamepad contents.
    /// - Returns: Returns a view containing the gamepad contents.
    @ViewBuilder private func gamepadContent() -> some View {
        
        VStack {
            if result1 != "" && entry == 1 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result1, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result2 != "" && entry == 2 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result2, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result3 != "" && entry == 3 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result3, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            HStack{
                GamepadMenuView(id: "ConvRes\(locationID)", menu: buildMenu(), fontSize: 24, gradientColors: menuGradient, selectedColors: menuSelectedGradient, maxEntries: maxEntries, boxWidth: gamepadMenuItemWidth, padding: 5.0)
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
    /// - Returns: Returns a view containing the iPhone contents.
    @ViewBuilder private func iPhoneContent() -> some View {
        VStack {
            if result1 != "" && entry == 1 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result1, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result2 != "" && entry == 2 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result3, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result3 != "" && entry == 3 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result3, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            HStack{
                IconButton(icon: "arrow.forward.circle", text: function, backgroundColor: MangaWorks.controlBackgroundColor) {
                    if function == "OK" {
                        MangaBook.shared.changeLayerVisibility(visibility: .displayNothing)
                    } else {
                        entry += 1
                    }
                }
                
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
    
    /// The iPad contents.
    /// - Returns: Returns a view containing the iPad contents.
    @ViewBuilder private func iPadContent() -> some View {
        VStack {
            if result1 != "" && entry == 1 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result1, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result2 != "" && entry == 2 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result2, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            if result3 != "" && entry == 3 {
                MangaConversationTextView(name: MangaWorks.expandMacros(in: name), message: MangaPage.sayPhrase(result3, inVoice: actor, shouldReadText: MangaStateManager.autoReadPage), boxWidth: boxWidth, boxHeight: boxHeight, topBoxHeight: topBoxHeight)
            }
            
            HStack{
                IconButton(icon: "arrow.forward.circle", text: function, backgroundColor: MangaWorks.controlBackgroundColor) {
                     if function == "OK" {
                         MangaBook.shared.changeLayerVisibility(visibility: .displayNothing)
                     } else {
                         entry += 1
                     }
                 }
                
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
    MangaConversationResultView( isGamepadConnected: .constant(false))
}
