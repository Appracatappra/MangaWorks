//
//  ContentTextView.swift
//  ReedWriteCycle
//
//  Created by Kevin Mullins on 2/27/23.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad
import SoundManager
import SpeechManager

/// Displays the fields for an inline Manga conversation.
public struct MangaConversationTextView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - name: The name of the conversation.
    ///   - message: The conversation message.
    ///   - font: The font to display the conversation in.
    ///   - fontColor: The font color.
    ///   - boxWidth: The control width.
    ///   - boxHeight: The control height.
    ///   - topBoxHeight: The top box height.
    public init(name: String = "", message: String = "", font: Font = ComicFonts.KomikaTight.ofSize(24), fontColor: Color = MangaWorks.conversationForegroundColor, boxWidth: CGFloat = MangaPageScreenMetrics.screenWidth, boxHeight: CGFloat = MangaPageScreenMetrics.screenHalfHeight, topBoxHeight: CGFloat = UIScreen.main.bounds.height / CGFloat(4.0)) {
        self.name = name
        self.message = message
        self.font = font
        self.fontColor = fontColor
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.topBoxHeight = topBoxHeight
    }
    
    // MARK: - Properties
    /// The name of the conversation.
    public var name:String = ""
    
    /// The conversation message.
    public var message:String = ""
    
    /// The font to display the conversation in.
    public var font:Font = ComicFonts.KomikaTight.ofSize(24)
    
    /// The font color.
    public var fontColor:Color = MangaWorks.conversationForegroundColor
    
    /// The control width.
    public var boxWidth:CGFloat = MangaPageScreenMetrics.screenWidth
    
    /// The control height.
    public var boxHeight:CGFloat = MangaPageScreenMetrics.screenHalfHeight
    
    /// The top box height.
    public var topBoxHeight:CGFloat = UIScreen.main.bounds.height / CGFloat(4.0)
    
    // MARK: - Computed Properties
    /// THe verical padding based on the device.
    private var paddingVertical:CGFloat {
        if HardwareInformation.isPhone {
            return 5.0
        } else {
            return 10.0
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
    
    /// The text width based on the device.
    private var textWidth:CGFloat {
        if HardwareInformation.isPhone {
            return boxWidth - 50
        } else {
            switch HardwareInformation.deviceOrientation {
            case .unknown:
                // HACK: The orientation is always reported as "unknown" as first draw, this code will handle that situation.
                if HardwareInformation.screenWidth > HardwareInformation.screenHeight {
                    return boxWidth - 200
                } else {
                    return boxWidth - 200
                }
            case .landscapeLeft,.landscapeRight:
                return boxWidth - 200
            default:
                return boxWidth - 200
            }
        }
    }
    
    /// The text Height based on the device.
    private var textHeight:CGFloat {
        if HardwareInformation.isPhone {
            return topBoxHeight - 130
        } else {
            switch HardwareInformation.deviceOrientation {
            case .unknown:
                // HACK: The orientation is always reported as "unknown" as first draw, this code will handle that situation.
                if HardwareInformation.screenWidth > HardwareInformation.screenHeight {
                    return topBoxHeight - 140
                } else {
                    return topBoxHeight - 140
                }
            case .landscapeLeft,.landscapeRight:
                return topBoxHeight - 140
            default:
                return topBoxHeight - 140
            }
        }
    }
    
    /// The control inset.
    private var inset:CGFloat {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 100
        }
    }
    
    /// The shadow radius.
    private var radius:CGFloat {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 25
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(MangaWorks.conversationBackgroundColor)
                .frame(width: boxWidth - inset, height: topBoxHeight - 100)
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(MangaWorks.controlBorderColor, lineWidth: 5)
                )
            
            VStack (alignment: .leading, spacing: 0) {
                HStack {
                    Text(markdown: MangaWorks.expandMacros(in: name))
                        .font(font)
                        .foregroundColor(MangaWorks.controlForegroundColor)
                        .padding(.horizontal, paddingHorizontal)
                        .padding(.top, paddingVertical)
                        .padding(.bottom, 0)
                        .background(.clear)
                    
                    Spacer()
                }
                
                HStack {
                    Text(markdown: MangaWorks.expandMacros(in: message))
                        .font(font)
                        .foregroundColor(fontColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(6)
                        .padding(.horizontal, paddingHorizontal)
                        .padding(.vertical, 0)
                        .frame(width: textWidth, height: textHeight, alignment: .topLeading)
                        .background(.clear)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .frame(width: boxWidth - inset, height: topBoxHeight - 100)
        }
    }
}

#Preview {
    MangaConversationTextView(name:"Sample Name", message: "Now is the time for all good men to come to the aid of their country. Now is the time for all good men to come to the aid of their country. Now is the time for all good men to come to the aid of their country. Now is the time for all good men to come to the aid of their country. Now is the time for all good men to come to the aid of their country.")
}
