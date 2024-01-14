//
//  GamePadSymbolEntry.swift
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

/// Allows the user to enter an in-game symbol via a gamepad based interface.
public struct MangaGamePadSymbolEntry: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - avatarImage: The avatar imageg to displsy in the input box.
    ///   - backgroundImage: The background image to display in the input box.
    ///   - symbol: The information for the symbol to enter.
    ///   - font: The font to draw the input control in.
    ///   - fontColor: The font color.
    ///   - boxWidth: The input control width.
    ///   - boxHeight: The input control height.
    ///   - editorID: The input control unique ID.
    public init(avatarImage: String = MangaWorks.inputAvatarImage, backgroundImage: String = MangaWorks.inputBackgroundImage, symbol: MangaPageSymbol, font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.controlForegroundColor, boxWidth: CGFloat = MangaPageScreenMetrics.screenHalfWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, editorID: String = "SymbolEntry") {
        self.avatarImage = avatarImage
        self.backgroundImage = backgroundImage
        self.symbol = symbol
        self.font = font
        self.fontColor = fontColor
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.editorID = editorID
    }
    
    // MARK: - Properties
    /// The avatar imageg to displsy in the input box.
    public var avatarImage:String = MangaWorks.inputAvatarImage
    
    /// The background image to display in the input box.
    public var backgroundImage:String = MangaWorks.inputBackgroundImage
    
    /// The information for the symbol to enter.
    public var symbol:MangaPageSymbol = MangaPageSymbol(title: "Please enter the sample Symbol:", symbolValue: "1111|0110|0110|1111", failLocation: "bad", succeedLocation: "good")
    
    /// The font to draw the input control in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// The input control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth
    
    /// The input control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The input control unique ID.
    public var editorID:String = "SymbolEntry"
    
    // MARK: - States
    /// The parretn buffer for the patter the user has entered.
    @State private var pattern:[Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    /// The cursor X position.
    @State private var cursorX:Int = 0
    
    /// The cursor Y position.
    @State private var cursorY:Int = 0
    
    /// The current element in focus.
    @State private var elementInFocus:String = "0x0"
    
    // MARK: - Computed Properties
    /// The vertical padding based on the device.
    private var paddingVertical:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 60.0
        }
    }
    
    /// The horizontal padding baed on the device.
    private var paddingHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 20.0
        }
    }
    
    /// The button font size based on the device.
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
    
    /// The text button size based on the device.
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
    
    /// The number button size based on the device.
    private var numberButtonSize:CGFloat {
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
            return 60
        }
    }
    
    /// The entry size based on the deivce.
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
    
    /// The entry width based on the device.
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
    
    /// The entry height based on the device.
    private var entryHeight:CGFloat {
        if HardwareInformation.isPhone {
            return 20
        } else {
            return 50
        }
    }
    
    /// The section padding based on the device.
    private var sectionPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 2
        } else {
            return 20
        }
    }
    
    /// The box size based on the device.
    private var boxSize:CGFloat {
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
            return 80
        }
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
                
                mainContent()
                
            }
            .frame(width: boxWidth, height: boxHeight, alignment: .center)
            .clipped()
        }
        .onAppear {
            dpadUsage(viewID: editorID, "Use the **Up**, **Down**, **Left** and **Right** arrows to highlight an **Entry Element** from the **Entry Form**.")
            buttonXUsage(viewID: editorID, "Activate the highlighted **Entry Element**. Turn the elements on an off to form a pattern.")
        }
        .onGamepadDpad(viewID: editorID) { xAxis, yAxis in
            let direction = GamepadMovementDirection.moving(x: xAxis, y: yAxis)
            switch direction {
            case .up:
                if cursorY > 0 {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                    cursorY -= 1
                }
            case .down:
                if cursorY < 3 {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                    cursorY += 1
                }
            case .left:
                if cursorX > 0 {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                    cursorX -= 1
                    if cursorX < 1 {
                        cursorY = 0
                    }
                }
            case .right:
                if cursorX < 4 {
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
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
                SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Menu_Select_00", ofType: "mp3"))
                SoundManager.shared.playSoundEffect(sound: "Menu_Select_00.mp3")
                switch cursorX {
                case 0:
                    // Enter
                    SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Electronic_06", ofType: "mp3"))
                    let desiredPattern = MangaWorks.expandMacros(in: symbol.symbolValue)
                    if desiredPattern != "" {
                        if symbolPattern() == desiredPattern {
                            MangaBook.shared.displayPage(id: symbol.succeedMangaPageID)
                        } else {
                            MangaBook.shared.displayPage(id: symbol.failMangaPageID)
                        }
                    } else {
                        if symbol.action != "" {
                            MangaWorks.runGraceScript(symbol.action)
                        } else {
                            MangaBook.shared.displayPage(id: symbol.failMangaPageID)
                        }
                    }
                default:
                    // Entering a number or symbol
                    switch cursorY {
                    case 0:
                        // First Row
                        switch cursorX {
                        case 1:
                            togglePixel(0)
                        case 2:
                            togglePixel(1)
                        case 3:
                            togglePixel(2)
                        case 4:
                            togglePixel(3)
                        default:
                            break
                        }
                    case 1:
                        // Second Row
                        switch cursorX {
                        case 1:
                            togglePixel(4)
                        case 2:
                            togglePixel(5)
                        case 3:
                            togglePixel(6)
                        case 4:
                            togglePixel(7)
                        default:
                            break
                        }
                    case 2:
                        // Third Row
                        switch cursorX {
                        case 1:
                            togglePixel(8)
                        case 2:
                            togglePixel(9)
                        case 3:
                            togglePixel(10)
                        case 4:
                            togglePixel(11)
                        default:
                            break
                        }
                    case 3:
                        // Fourth Row
                        switch cursorX {
                        case 1:
                            togglePixel(12)
                        case 2:
                            togglePixel(13)
                        case 3:
                            togglePixel(14)
                        case 4:
                            togglePixel(15)
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
    /// Draw the main contents of the control.
    /// - Returns: Returns a view containing the main contents.
    @ViewBuilder private func mainContent() -> some View {
        if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.3) {
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
            
        }
        
        HStack {
            entryView()
            
            Spacer()
            
            patternView()
        }
    }
    
    /// Drawes the entry section
    /// - Returns: Returns a view with the entry section.
    @ViewBuilder private func entryView() -> some View {
        VStack {
            Text(markdown: MangaWorks.expandMacros(in: symbol.title))
                .font(font)
                .foregroundColor(fontColor)
                .padding(.horizontal, paddingHorizontal)
                .padding(.top, paddingVertical)
                .background(.clear)
                .shadow(radius: 5.0)
            
            MangaFocusableTextPanel(title: "Enter", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .white, focusID: "0x0", elementInFocus: $elementInFocus)
        }
    }
    
    /// Draws the pattern section.
    /// - Returns: Returns a view with the pattern section.
    @ViewBuilder private func patternView() -> some View {
        VStack(spacing: 0.0) {
            // First Row
            HStack(spacing: 0.0) {
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "1x0", borderFocus: true, isEnabled: pattern[0], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "2x0", borderFocus: true, isEnabled: pattern[1], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "3x0", borderFocus: true, isEnabled: pattern[2], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "4x0", borderFocus: true, isEnabled: pattern[3], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
            }
            
            // Second Row
            HStack(spacing: 0.0) {
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "1x1", borderFocus: true, isEnabled: pattern[4], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "2x1", borderFocus: true, isEnabled: pattern[5], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "3x1", borderFocus: true, isEnabled: pattern[6], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "4x1", borderFocus: true, isEnabled: pattern[7], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
            }
            
            // Third Row
            HStack(spacing: 0.0) {
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "1x2", borderFocus: true, isEnabled: pattern[8], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "2x2", borderFocus: true, isEnabled: pattern[9], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "3x2", borderFocus: true, isEnabled: pattern[10], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "4x2", borderFocus: true, isEnabled: pattern[11], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
            }
            
            // Fourth Row
            HStack(spacing: 0.0) {
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "1x3", borderFocus: true, isEnabled: pattern[12], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "2x3", borderFocus: true, isEnabled: pattern[13], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "3x3", borderFocus: true, isEnabled: pattern[14], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
                
                MangaFocusableTextPanel(title: " ", font: ComicFonts.goodTimes.ofSize(textButtonFontSize), enabledColor: .orange, focusID: "4x3", borderFocus: true, isEnabled: pattern[15], isFixedFize: true, boxWidth: boxSize, boxHeight: boxSize, isPixel: true, elementInFocus: $elementInFocus)
            }
        }
        .padding(.trailing)
    }
    
    /// Toggles the on/off state of a pixel.
    /// - Parameter n: The pixel to toggle.
    private func togglePixel(_ n:Int) {
        pattern[n] = !pattern[n]
    }
    
    /// Converts the symbol into a 1 and 0 pattern.
    /// - Returns: Returns the pattern the user has entered.
    private func symbolPattern() -> String {
        var value:String = ""
        
        value = pixelValue(0)
        value += pixelValue(1)
        value += pixelValue(2)
        value += pixelValue(3)
        
        value += "|"
        
        value += pixelValue(4)
        value += pixelValue(5)
        value += pixelValue(6)
        value += pixelValue(7)
        
        value += "|"
        
        value += pixelValue(8)
        value += pixelValue(9)
        value += pixelValue(10)
        value += pixelValue(11)
        
        value += "|"
        
        value += pixelValue(12)
        value += pixelValue(13)
        value += pixelValue(14)
        value += pixelValue(15)
        
        //Debug.info(subsystem: "GamePadSymbolEntry", category: "symbolPattern", "Pattern: \(value)")
        
        return value
    }
    
    /// Gets the pixel value.
    /// - Parameter n: The element to get the pattern for.
    /// - Returns: Returns a "1" or a "0" based on the pixel state.
    private func pixelValue(_ n:Int) -> String {
        if pattern[n] {
            return "1"
        } else {
            return "0"
        }
    }
}

#Preview {
    MangaGamePadSymbolEntry(symbol: MangaPageSymbol(title: "Please enter the sample Symbol:", symbolValue: "1111|0110|0110|1111", failLocation: "bad", succeedLocation: "good"))
}
