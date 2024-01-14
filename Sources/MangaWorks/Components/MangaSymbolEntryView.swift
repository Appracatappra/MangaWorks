//
//  SymbolEntryView.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 11/2/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SwiftUIGamepad
import SoundManager

/// Allows the user to enter a symbol on touch based devices.
public struct MangaSymbolEntryView: View {
    
    // MARK: - Initializers
    /// Creates a new instances.
    /// - Parameters:
    ///   - avatarImage: The avatar imageg to displsy in the input box.
    ///   - backgroundImage: The background image to display in the input box.
    ///   - symbol: The information on the symbol to enter.
    ///   - font: The font to displa ythe control in.
    ///   - fontColor: The font color.
    ///   - boxWidth: The control box width.
    ///   - boxHeight: The control box height.
    ///   - pageWidth: The full page width.
    ///   - pageHeight: The full page height.
    ///   - borderColor: The control border color.
    public init(avatarImage: String = MangaWorks.inputAvatarImage, backgroundImage: String = MangaWorks.inputBackgroundImage, symbol: MangaPageSymbol = MangaPageSymbol(from: ""), font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.controlForegroundColor, boxWidth: CGFloat = MangaPageScreenMetrics.screenWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, pageWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth, pageHeight:CGFloat = MangaPageScreenMetrics.screenHeight, borderColor: Color = MangaWorks.controlBorderColor) {
        self.avatarImage = avatarImage
        self.backgroundImage = backgroundImage
        self.symbol = symbol
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
    
    /// The information on the symbol to enter.
    public var symbol:MangaPageSymbol = MangaPageSymbol(title: "Please enter the sample Symbol:", symbolValue: "1111|0110|0110|1111", failLocation: "bad", succeedLocation: "good")
    
    /// The font to displa ythe control in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// The control box width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenWidth
    
    /// The control box height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The input page width.
    public var pageWidth:CGFloat = MangaPageScreenMetrics.screenHalfWidth
    
    /// The input page height.
    public var pageHeight:CGFloat = MangaPageScreenMetrics.screenHeight
    
    /// The control border color.
    public var borderColor:Color = MangaWorks.controlBorderColor
    
    // MARK: - States
    /// Holds the pattern being entered by the user.
    @State private var pattern:[Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
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
    
    /// The button size.
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
    
    /// The text button size.
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
    
    /// The entry width.
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
    
    /// The entry height.
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
    
    // MARK: - Control Body
    /// The body of the control.
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
    /// - Returns: Returns a view with the iPhone contents.
    @ViewBuilder private func iPhoneView() -> some View {
        if let sourceImage = UIImage.asset(named: avatarImage, atScale: 0.2) {
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
            
        }
        
        VStack {
            entryView()
            
            patternView()
        }
    }
    
    /// Draws the iPad contents.
    /// - Returns: Returns a view with the iPad contents.
    @ViewBuilder private func iPadView() -> some View {
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
    
    /// Draws the entry contents.
    /// - Returns: Returns a view with the entry contents.
    @ViewBuilder private func entryView() -> some View {
        VStack {
            if !HardwareInformation.isPhone {
                Text(markdown: MangaWorks.expandMacros(in: symbol.title))
                    .font(font)
                    .foregroundColor(fontColor)
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.top, paddingVertical)
                    .background(.clear)
                    .shadow(radius: 5.0)
            }
            
            MangaTextButton(title: "Enter", font: font, enabledColor: .white){
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
            }
            .padding()
            .border(borderColor, width: 4)
            .background(MangaWorks.controlBackgroundColor)
            
            Spacer()
        }
    }
    
    /// Draws the pattern contents.
    /// - Returns: Returns a view with the patters contents.
    @ViewBuilder private func patternView() -> some View {
        VStack {
            HStack {
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[0] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[1] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[2] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[3] = isOn
                }
            }
            
            HStack {
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[4] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[5] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[6] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[7] = isOn
                }
            }
            
            HStack {
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[8] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[9] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[10] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[11] = isOn
                }
            }
            
            HStack {
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[12] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[13] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[14] = isOn
                }
                
                MangaPixelButton(width: numberButtonSize, height: numberButtonSize) { isOn in
                    pattern[15] = isOn
                }
            }
        }
        .padding(.trailing)
    }
    
    /// Calculates the symbol pattern.
    /// - Returns: Returns the computed patters and "1" and "0'.
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
        
        //Debug.info(subsystem: "SymbolEntryView", category: "symbolPattern", "Pattern: \(value)")
        
        return value
    }
    
    /// Converts the state to a "1" or "0".
    /// - Parameter n: The state to convert.
    /// - Returns: Returns the state as a "1" or a "0".
    private func pixelValue(_ n:Int) -> String {
        if pattern[n] {
            return "1"
        } else {
            return "0"
        }
    }
}

#Preview {
    MangaSymbolEntryView(symbol: MangaPageSymbol(title: "Please enter the sample Symbol:", symbolValue: "1111|0110|0110|1111", failLocation: "bad", succeedLocation: "good"))
}
