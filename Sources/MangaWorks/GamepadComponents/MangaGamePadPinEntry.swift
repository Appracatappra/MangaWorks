//
//  GamePadPinEntry.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 11/17/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SoundManager

/// Allows the user to enter an in-game PIN Number via a gamepad based interface.
public struct MangaGamePadPinEntry: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - avatarImage: The avatar imageg to displsy in the input box.
    ///   - backgroundImage: The background image to display in the input box.
    ///   - pin: The information for the PIN entry.
    ///   - font: The font to draw the input in.
    ///   - fontColor: The font to draw the input in.
    ///   - boxWidth: The input width.
    ///   - boxHeight: The Input Height.
    ///   - borderColor: The input border color.
    ///   - editorID: The unique id of the editor.
    public init(avatarImage: String = MangaWorks.inputAvatarImage, backgroundImage: String = MangaWorks.inputBackgroundImage, pin: MangaPagePin, font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.controlForegroundColor, boxWidth: CGFloat = MangaPageScreenMetrics.screenHalfWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, borderColor: Color  = MangaWorks.controlBorderColor, editorID:String = "PinEntry") {
        self.avatarImage = avatarImage
        self.backgroundImage = backgroundImage
        self.pin = pin
        self.font = font
        self.fontColor = fontColor
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.borderColor = borderColor
        self.editorID = editorID
    }
    
    // MARK: - Properties
    /// The avatar imageg to displsy in the input box.
    public var avatarImage:String = MangaWorks.inputAvatarImage
    
    /// The background image to display in the input box.
    public var backgroundImage:String = MangaWorks.inputBackgroundImage
    
    /// The information for the PIN entry.
    public var pin:MangaPagePin = MangaPagePin(title: "Please enter the sample PIN:", pinValue: "012345", failLocation: "bad", succeedLocation: "good")
    
    /// The font to draw the input in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// The input width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth
    
    /// The Input Height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The input border color.
    public var borderColor:Color = MangaWorks.controlBorderColor
    
    /// The unique id of the editor.
    public var editorID:String = "PinEntry"
    
    // MARK: - States
    /// The current value the user has entered.
    @State private var value:String = ""
    
    /// The cursor X location.
    @State private var cursorX:Int = 0
    
    /// The cursor Y location.
    @State private var cursorY:Int = 0
    
    /// The current element in focus.
    @State private var elementInFocus:String = "0x0"
    
    // MARK: - Computed Properties
    /// Get the vertical padding base on the device.
    private var paddingVertical:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 60.0
        }
    }
    
    /// Get the horizontal padding based on the device.
    private var paddingHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 20.0
        }
    }
    
    /// Get the button font size.
    private var buttonFontSize:Float {
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
    
    /// Get the text button font size
    private var textButtonFontSize:Float {
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
    
    /// The number button size.
    private var numberButtonSize:CGFloat {
        if HardwareInformation.isPhone {
            return 10
        }  else {
            return 50
        }
    }
    
    /// The entry font size.
    private var entryFontSize:Float {
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
    
    /// The entry field width.
    private var entryWidth:CGFloat {
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
    
    /// The entry field height.
    private var entryHeight:CGFloat {
        if HardwareInformation.isPhone {
            return 20
        } else {
            return 50
        }
    }
    
    /// The section padding.
    private var sectionPadding:CGFloat {
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
    
    // MARK: - Main Contents
    /// The contents of the control.
    public var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if let sourceImage = UIImage.asset(named: backgroundImage, atScale: 1.0) {
                    Image(uiImage: sourceImage)
                        .resizable()
                }
                
                mainContents()
                
            }
            .frame(width: boxWidth, height: boxHeight, alignment: .center)
            .clipped()
        }
        .onAppear {
            dpadUsage(viewID: editorID, "Use the **Up**, **Down**, **Left** and **Right** arrows to highlight an **Entry Element** from the **Entry Form**.")
            buttonXUsage(viewID: editorID, "Activate the highlighted **Entry Element**.")
        }
        .onGamepadDpad(viewID: editorID) { xAxis, yAxis in
            let direction = GamepadMovementDirection.moving(x: xAxis, y: yAxis)
            switch direction {
            case .up:
                if cursorY > 0 {
                    SoundManager.shared.playSoundEffect(sound: "Click_Standard_05.mp3")
                    cursorY -= 1
                }
            case .down:
                if cursorY < 3 {
                    SoundManager.shared.playSoundEffect(sound: "Click_Standard_05.mp3")
                    cursorY += 1
                }
            case .left:
                if cursorX > 0 {
                    SoundManager.shared.playSoundEffect(sound: "Click_Standard_05.mp3")
                    cursorX -= 1
                    if cursorX < 2 {
                        cursorY = 0
                    }
                }
            case .right:
                if cursorX < 4 {
                    SoundManager.shared.playSoundEffect(sound: "Click_Standard_05.mp3")
                    cursorX += 1
                }
            default:
                break
            }
            if direction != .none {
                elementInFocus = "\(cursorX)x\(cursorY)"
            }
        }
        .onGamepadButtonX(viewID: editorID) {ispressed in
            if ispressed {
                SoundManager.shared.playSoundEffect(sound: "Menu_Select_00.mp3")
                switch cursorX {
                case 0:
                    // Clear
                    value = ""
                case 1:
                    // Enter
                    if value == validPIN {
                        MangaBook.shared.displayPage(id: pin.succeedMangaPageID)
                        MangaWorks.runGraceScript(pin.action)
                    } else {
                        MangaBook.shared.displayPage(id: pin.failMangaPageID)
                    }
                default:
                    guard value.count < 7 else {
                        break
                    }
                    
                    // Entering a number or symbol
                    switch cursorY {
                    case 0:
                        // First Row
                        switch cursorX {
                        case 2:
                            value += "1"
                        case 3:
                            value += "2"
                        case 4:
                            value += "3"
                        default:
                            break
                        }
                    case 1:
                        // Second Row
                        switch cursorX {
                        case 2:
                            value += "4"
                        case 3:
                            value += "5"
                        case 4:
                            value += "6"
                        default:
                            break
                        }
                    case 2:
                        // Third Row
                        switch cursorX {
                        case 2:
                            value += "7"
                        case 3:
                            value += "8"
                        case 4:
                            value += "9"
                        default:
                            break
                        }
                    case 3:
                        // Fourth Row
                        switch cursorX {
                        case 2:
                            value += "*"
                        case 3:
                            value += "0"
                        case 4:
                            value += "#"
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Functions
    /// Draws the main body of the control.
    /// - Returns: Returns a view with the main body of the control.
    @ViewBuilder private func mainContents() -> some View {
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
    
    /// Draws the entry section of the control.
    /// - Returns: Returns a view with the entry section of the control.
    @ViewBuilder private func entryView() -> some View {
        VStack {
            Text(markdown: MangaWorks.expandMacros(in: pin.title))
                .font(font)
                .foregroundColor(fontColor)
                .padding(.horizontal, paddingHorizontal)
                .padding(.top, paddingVertical)
                .background(.clear)
                .shadow(radius: 5.0)
            
            Text(value)
                .font(ComicFonts.bitwise.ofSize(entryFontSize))
                .foregroundColor(fontColor)
                .frame(width: entryWidth, height: entryHeight)
                .padding()
                .border(borderColor, width: 4)
            
            HStack {
                MangaFocusableTextPanel(title: "Clear", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "0x0", elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "Enter", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "1x0", elementInFocus: $elementInFocus)
            }
        }
        .padding(.all, sectionPadding)
    }
    
    /// Draws the number section of the control.
    /// - Returns: Returns a view with the number section of the control.
    @ViewBuilder private func numberView() -> some View {
        VStack {
            // First Row
            HStack {
                MangaFocusableTextPanel(title: "1", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "2x0", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "2", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "3x0", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "3", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "4x0", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
            }
            
            // Second Row
            HStack {
                MangaFocusableTextPanel(title: "4", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "2x1", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "5", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "3x1", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "6", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "4x1", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
            }
            
            // Third Row
            HStack {
                MangaFocusableTextPanel(title: "7", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "2x2", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "8", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "3x2", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "9", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "4x2", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
            }
            
            // Fourth Row
            HStack {
                MangaFocusableTextPanel(title: "*", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "2x3", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "0", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "3x3", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: "#", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "4x3", isFixedFize: true, boxWidth: numberButtonSize, boxHeight: numberButtonSize, elementInFocus: $elementInFocus)
            }
        }
        .padding(.all, sectionPadding)
    }
}

#Preview {
    MangaGamePadPinEntry(pin: MangaPagePin(title: "Please enter the sample PIN:", pinValue: "012345", failLocation: "bad", succeedLocation: "good"))
}
