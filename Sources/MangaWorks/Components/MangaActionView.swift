//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SoundManager
import LogManager

/// Displays a `MangaPageAction` for the user to interact with.
public struct MangaActionView: View {
    
    // MARK: - Initializers
    /// Creates an empty instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - text: The text to display in the action.
    ///   - font: The font to display the text in.
    ///   - fontSize: The font size to display the text in.
    ///   - fontColor: The color to display the font in.
    ///   - backgroundColor: The action box background color.
    ///   - isWide: If `true` this is a wide view.
    ///   - action: The Grace Language script to execute if the user selects this action.
    public init(text: String = "", font: ComicFonts = .KomikaTight, fontSize: Float = 24, fontColor: Color = MangaWorks.actionFontColor, backgroundColor: Color = MangaWorks.actionBackgroundColor, isWide: Bool = false, action: String = "") {
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.isWide = isWide
        self.action = action
    }
    
    // MARK: - Properties
    /// The text to display in the action.
    public var text:String = ""
    
    /// The font to display the text in.
    public var font:ComicFonts = .KomikaTight
    
    /// The font size to display the text in.
    public var fontSize:Float = 24
    
    /// The color to display the font in.
    public var fontColor:Color = MangaWorks.actionFontColor
    
    /// The action box background color.
    public var backgroundColor:Color = MangaWorks.actionBackgroundColor
    
    /// If `true` this is a wide view.
    public var isWide:Bool = false
    
    /// The Grace Language script to execute if the user selects this action.
    public var action:String = ""
    
    /// Gets the action box with based on the device and orientation.
    private var boxWidth:Float {
        if HardwareInformation.isPhone {
            switch HardwareInformation.screenWidth {
            case 375:
                return 220
            case 390, 393:
                return 240
            default:
                return 280
            }
        } else if HardwareInformation.isPad {
            if isWide {
                return 350
            } else {
                switch HardwareInformation.deviceOrientation {
                case .unknown:
                    return 200
                case .landscapeLeft, .landscapeRight:
                    return 200
                default:
                    return 300
                }
            }
        } else if HardwareInformation.screenWidth == 1024 {
            return 360
        } else {
            return 300
        }
    }
    
    /// Calculates the title size based on the device.
    private var titleSize:Float {
        if HardwareInformation.isPhone {
            return 18
        } else {
            
            return fontSize * HardwareInformation.deviceRatioWidth
        }
    }
    
    /// Gets the title by expanding any Grace Language macros in the text provided.
    private var title:String {
        do {
            return try GraceRuntime.shared.expandMacros(in: text)
        } catch {
            Log.error(subsystem: "MangaWorks", category: "MangaActionView", "Error: \(error)")
            return text
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        Button(action: {
            Execute.onMain {
                SpeechManager.shared.stopSpeaking()
                SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Click_Standard_05", ofType: "mp3"))
                if action != "" {
                    MangaWorks.runGraceScript(action)
                }
            }
        }) {
            Text(markdown: title)
                .font(font.ofSize(titleSize))
                .foregroundColor(fontColor)
                .padding(.all)
                .frame(width: CGFloat(boxWidth))
                .border(MangaWorks.actionBorderColor, width: 4)
                .background(backgroundColor)
                .cornerRadius(10.0)
        }
    }
}

#Preview {
    MangaActionView(text: "This is an action that the user can take. It could be quite long and descriptive.")
}
