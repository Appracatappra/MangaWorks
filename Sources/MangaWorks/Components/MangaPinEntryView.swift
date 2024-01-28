//
//  PinEntryView.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 3/14/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SwiftUIGamepad
import SoundManager

/// Allows the user to enter an in-game PIN Number using touch based input.
public struct MangaPinEntryView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - avatarImage: The avatar imageg to displsy in the input box.
    ///   - backgroundImage: The background image to display in the input box.
    ///   - pin: The Information for the pin to enter.
    ///   - font: The font to draw the control in.
    ///   - fontColor: The font color.
    ///   - boxWidth: The control width.
    ///   - boxHeight: The control height.
    ///   - pageWidth: The full page width.
    ///   - pageHeight: The full page height.
    ///   - borderColor: The control border color.
    public init(avatarImage: String = MangaWorks.inputAvatarImage, backgroundImage: String = MangaWorks.inputBackgroundImage, pin: MangaPagePin = MangaPagePin(title: ""), font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.controlForegroundColor, boxWidth: CGFloat = MangaPageScreenMetrics.screenWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, pageWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth, pageHeight:CGFloat = MangaPageScreenMetrics.screenHeight, borderColor: Color = MangaWorks.controlBorderColor) {
        self.avatarImage = avatarImage
        self.backgroundImage = backgroundImage
        self.pin = pin
        self.font = font
        self.fontColor = fontColor
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        self.borderColor = borderColor
    }
    
    // MARK: - Properties
    /// The avatar imageg to displsy in the input box.
    public var avatarImage:String = MangaWorks.inputAvatarImage
    
    /// The background image to display in the input box.
    public var backgroundImage:String = MangaWorks.inputBackgroundImage
    
    /// The Information for the pin to enter.
    public var pin:MangaPagePin = MangaPagePin(title: "Please enter the sample PIN:", pinValue: "012345", failLocation: "bad", succeedLocation: "good")
    
    /// The font to draw the control in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// The control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenWidth
    
    /// The control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The input page width.
    public var pageWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth
    
    /// The input page height.
    public var pageHeight:CGFloat = MangaPageScreenMetrics.screenHeight
    
    /// The control border color.
    public var borderColor:Color = MangaWorks.controlBorderColor
    
    // MARK: - States
    /// The value the user has currently entered.
    @State private var value:String = ""
    
    // MARK: - Computed Properties
    /// The vertical padding based on the device.
    var paddingVertical:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 60.0
        }
    }
    
    /// The horizontal padding based on the device.
    var paddingHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 20.0
        }
    }
    
    /// The button font size based on the device.
    var buttonFontSize:Float {
        if HardwareInformation.isPhone {
            return 18
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 16
            default:
                return 24
            }
        } else {
            return 24
        }
    }
    
    /// The button text size based on the device.
    var textButtonFontSize:Float {
        if HardwareInformation.isPhone {
            return 14
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 14
            default:
                return 24
            }
        } else {
            return 24
        }
    }
    
    /// The number size based on the device.
    var numberButtonSize:CGFloat {
        if HardwareInformation.isPhone {
            return 10
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 20
            default:
                return 30
            }
        } else {
            return 30
        }
    }
    
    /// The entry font size.
    var entryFontSize:Float {
        if HardwareInformation.isPhone {
            return 30
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 32
            default:
                return 42
            }
        } else {
            return 42
        }
    }
    
    /// The entry width.
    var entryWidth:CGFloat {
        if HardwareInformation.isPhone {
            return 240
        } else if HardwareInformation.isPad {
            switch HardwareInformation.deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                return 180
            default:
                return 240
            }
        } else {
            return 240
        }
    }
    
    /// The entry height.
    var entryHeight:CGFloat {
        if HardwareInformation.isPhone {
            return 20
        } else {
            return 50
        }
    }
    
    /// The section padding.
    var sectionPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 2
        } else {
            return 20
        }
    }
    
    /// The value for a valid pin number.
    private var validPIN:String {
        return MangaWorks.expandMacros(in: pin.pinValue)
    }
    
    // MARK: - Control Body
    /// The body of the contr
    public var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if let sourceImage = UIImage.asset(named: backgroundImage, atScale: 1.0) {
                    Image(uiImage: sourceImage)
                        .resizable()
                }
                
                if HardwareInformation.isPhone {
                    iPhoneView()
                } else {
                    iPadView()
                }
                
            }
            .frame(width: boxWidth, height: boxHeight, alignment: .center)
            .clipped()
        }
        .frame(width: pageWidth, height: pageHeight)
    }
    
    // MARK: - Functions
    /// Draws the iPhone contents.
    /// - Returns: Returns a view with the iPhone Contents.
    @ViewBuilder func iPhoneView() -> some View {
        if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.2) {
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
                
        }
        
        VStack {
            entryView()
            
            numberView()
        }
    }
    
    /// Draws the iPad contents.
    /// - Returns: Returns a view with the iPad contents.
    @ViewBuilder func iPadView() -> some View {
        if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.3) {
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
                
        }
        
        HStack {
            entryView()
            
            Spacer()
            
            numberView()
        }
    }
    
    /// Draws the entry contents.
    /// - Returns: Returns a view with the entry contents.
    @ViewBuilder func entryView() -> some View {
        VStack {
            if !HardwareInformation.isPhone {
                Text(markdown: MangaWorks.expandMacros(in: pin.title))
                    .font(font)
                    .foregroundColor(fontColor)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                    .shadow(radius: 5.0)
            }
            
            Text(value)
                .font(ComicFonts.bitwise.ofSize(entryFontSize))
                .foregroundColor(fontColor)
                .frame(width: entryWidth, height: entryHeight)
                .padding()
                .border(borderColor, width: 4)
            
            HStack {
                MangaTextButton(title: "Clear", font: font, enabledColor: .white){
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
                    value = ""
                }
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "Enter", font: font, enabledColor: .white){
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
                    if value == validPIN {
                        if pin.succeedMangaPageID == "" {
                            MangaBook.shared.setStateBool(key: "PINCorrect", value: true)
                            MangaWorks.runGraceScript(pin.action)
                        } else {
                            MangaBook.shared.displayPage(id: pin.succeedMangaPageID)
                        }
                    } else {
                        if pin.failMangaPageID == "" {
                            MangaBook.shared.setStateBool(key: "PINCorrect", value: false)
                            MangaWorks.runGraceScript(pin.action)
                        } else {
                            MangaBook.shared.displayPage(id: pin.failMangaPageID)
                        }
                    }
                }
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
            }
        }
        .padding(.all, sectionPadding)
    }
    
    /// Draws a number contents.
    /// - Returns: Returns a view with the number contents.
    @ViewBuilder func numberView() -> some View {
        VStack {
            HStack {
                MangaTextButton(title: "1", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "1"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "2", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "2"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "3", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "3"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
            }
            
            HStack {
                MangaTextButton(title: "4", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "4"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "5", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "5"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "6", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "6"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
            }
            
            HStack {
                MangaTextButton(title: "7", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "7"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "8", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "8"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "9", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "9"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
            }
            
            HStack {
                MangaTextButton(title: "*", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "*"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "0", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "0"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
                
                MangaTextButton(title: "#", font: font, enabledColor: .white){
                    if value.count < 7 {
                        SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                        value += "#"
                    }
                }
                .frame(width: numberButtonSize, height: numberButtonSize)
                .padding()
                .border(borderColor, width: 4)
                .background(MangaWorks.controlBackgroundColor)
            }
        }
        .padding(.all, sectionPadding)
    }
}

#Preview {
    MangaPinEntryView(pin: MangaPagePin(title: "Please enter the sample PIN:", pinValue: "012345", failLocation: "bad", succeedLocation: "good"))
}
