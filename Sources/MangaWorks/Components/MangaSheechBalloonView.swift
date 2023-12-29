//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 12/29/23.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager

/// Displays the contents of a speech ballon in a manga page.
public struct MangaSheechBalloonView: View {
    
    // MARK: - Properties
    /// Defines the type of speech balloon to display.
    public var type:MangaSpeechBalloon.BalloonType = .talk
    
    /// The caption to display in the speech balloon.
    public var caption:String = ""
    
    /// Where the tail of the speech balloon should be displayed.
    public var tail:MangaSpeechBalloon.TailOrientation = .bottomTrailing
    
    /// The font to display the caption in.
    public var font:ComicFonts = .KomikaTight
    
    /// The caption font size.
    public var fontSize:Float = 24
    
    /// The caption font color.
    public var fontColor:Color = Color.black
    
    /// The caption background color.
    public var backgroundColor:Color = Color.white
    
    /// The caption box width
    public var boxWidth:Float = 200.0
    
    /// The caption X offset.
    public var xOffset:Float = 0.0
    
    /// The caption X offset.
    public var yOffset:Float = 0.0
    
    // MARK: - Environmental Properties
    /// The `MangaAnimation` controller for the speech balloon.
    @EnvironmentObject private var animation:MangaAnimation
    
    /// If `true`, the caption will be read aloud when the user taps on it.
    @AppStorage("readOnTap") private var readOnTap: Bool = false
    
    /// If `true` the text is expanded to full screen if the user taps on it.
    @AppStorage("expandOnTap") private var expandOnTap: Bool = true
    
    // MARK: - Computed Properties
    private var text:String {
        var value = ""
        
        do {
            try value = GraceRuntime.shared.expandMacros(in: caption)
        } catch {
            value = caption
        }
        
        return value
    }
    
    /// Get the text alignment for the caption.
    private var align:Alignment {
        switch type {
        case .telepathic:
            return .center
        default:
            return tail.alignment
        }
    }
    
    /// Get the horizontal padding for the caption.
    private var paddingHorizontal:CGFloat {
        switch type {
        case .scream:
            return CGFloat(boxWidth * 0.20)
        case .telepathic:
            return CGFloat(boxWidth * 0.08)
        case.weak:
            return CGFloat(boxWidth * 0.10)
        case.think:
            return CGFloat(boxWidth * 0.10)
        default:
            return CGFloat(20.0 * HardwareInformation.deviceRatio)
        }
    }
    
    /// Get the top padding for the caption.
    private var paddingTop:CGFloat {
        var value:Float = 0.0
        
        switch type {
        case .electronic, .think:
            switch tail {
            case .topLeading, .topTrailing:
                value = 60.0
            case .bottomLeading, .bottomTrailing:
                value = 50.0
            }
        case .weak:
            switch tail {
            case .topLeading, .topTrailing:
                value = 120.0
            case .bottomLeading, .bottomTrailing:
                value = 50.0
            }
        case .telepathic:
            return 70
        case .scream:
            switch tail {
            case .topLeading, .topTrailing:
                value = 80
            case .bottomLeading, .bottomTrailing:
                value = 50.0
            }
        case .robot:
            switch tail {
            case .topLeading, .topTrailing:
                value = 55.0
            case .bottomLeading, .bottomTrailing:
                value = 10.0
            }
        case .loudSpeaker:
            switch tail {
            case .topLeading, .topTrailing:
                value = 95.0
            case .bottomLeading, .bottomTrailing:
                value = 85.0
            }
        default:
            switch tail {
            case .topLeading, .topTrailing:
                if boxWidth <= 200 {
                    value = 70.0
                } else {
                    value = 50.0
                }
            case .bottomLeading, .bottomTrailing:
                value = 10.0
            }
        }
        
        return CGFloat(value * HardwareInformation.deviceRatioHeight)
    }
    
    /// Get the bottom padding for the caption.
    private var paddingBottom:CGFloat {
        var value:Float = 0.0
        
        switch type {
        case .electronic, .think:
            switch tail {
            case .topLeading, .topTrailing:
                value = 50.0
            case .bottomLeading, .bottomTrailing:
                value = 70.0
            }
        case .weak:
            switch tail {
            case .topLeading, .topTrailing:
                value = 50.0
            case .bottomLeading, .bottomTrailing:
                value = 120.0
            }
        case .telepathic:
            value = 60
        case .scream:
            switch tail {
            case .topLeading, .topTrailing:
                value = 50.0
            case .bottomLeading, .bottomTrailing:
                value = 80.0
            }
        case .robot:
            switch tail {
            case .topLeading, .topTrailing:
                value = 10.0
            case .bottomLeading, .bottomTrailing:
                value = 55.0
            }
        case .loudSpeaker:
            switch tail {
            case .topLeading, .topTrailing:
                value = 90.0
            case .bottomLeading, .bottomTrailing:
                value = 95.0
            }
        default:
            switch tail {
            case .topLeading, .topTrailing:
                value = 10.0
            case .bottomLeading, .bottomTrailing:
                if boxWidth <= 200 {
                    value = 70.0
                } else {
                    value = 50.0
                }
            }
        }
        
        return CGFloat(value * HardwareInformation.deviceRatioHeight)
    }
    
    /// Get the leading padding for the caption.
    private var paddingLeading:CGFloat {
        var value:Float = 0.0
        
        switch type {
        case .weak:
            value = 50
        case .think:
            value = 30
        case .telepathic:
            value = 30
        case .scream:
            value = 100
        case .loudSpeaker:
            value = 70
        default:
            value = 15
        }
        
        return CGFloat(value * HardwareInformation.deviceRatioWidth)
    }
    
    /// Get the trailing padding for the caption.
    private var paddingTrailing:CGFloat {
        var value:Float = 0.0
        
        switch type {
        case .weak:
            value = 50
        case .think:
            value = 20
        case .telepathic:
            value = 30
        case .scream:
            value = 100
        case .loudSpeaker:
            value = 70
        default:
            value = 15
        }
        
        return CGFloat(value * HardwareInformation.deviceRatioWidth)
    }
    
    /// Read the image from the package bundle
    private var image:UIImage? {
        let url = MangaWorks.urlTo(resource: type.rawValue, withExtension: "png")
        return UIImage.scaledImage(bundleURL: url, scale: 1.0)
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        if animation.isAnimated {
            contents()
            .opacity(animation.currentOpacity)
            .offset(x: animation.currentOffsetX, y: animation.currentOffsetY)
            .rotationEffect(Angle(degrees: animation.currentRotationDegrees))
            .onAppear {
                Execute.afterDelay(seconds: animation.delay) {
                    if animation.repeats {
                        if animation.cycles == 0 {
                            withAnimation(.easeIn(duration: animation.duration).repeatForever(autoreverses: animation.autoReverse)) {
                                animation.currentOpacity = animation.opacityEnd
                                animation.currentOffsetX = animation.xOffsetEnd
                                animation.currentOffsetY = animation.yOffsetEnd
                                animation.currentRotationDegrees = animation.rotationDegreesEnd
                            }
                        } else {
                            withAnimation(.easeIn(duration: animation.duration).repeatCount(animation.cycles, autoreverses: animation.autoReverse)) {
                                animation.currentOpacity = animation.opacityEnd
                                animation.currentOffsetX = animation.xOffsetEnd
                                animation.currentOffsetY = animation.yOffsetEnd
                                animation.currentRotationDegrees = animation.rotationDegreesEnd
                            }
                        }
                    } else {
                        withAnimation(.easeIn(duration: animation.duration)) {
                            animation.currentOpacity = animation.opacityEnd
                            animation.currentOffsetX = animation.xOffsetEnd
                            animation.currentOffsetY = animation.yOffsetEnd
                            animation.currentRotationDegrees = animation.rotationDegreesEnd
                        }
                    }
                }
            }
        } else {
            contents()
        }
    }
    
    // MARK: - Functions
    @ViewBuilder
    func contents() -> some View {
        ZStack {
            Text(markdown: text)
                .font(font.ofSize(fontSize))
                .foregroundColor(fontColor)
                .frame(width: CGFloat(boxWidth))
                .padding(.top, paddingTop)
                .padding(.bottom, paddingBottom)
                .padding(.leading, paddingLeading)
                .padding(.trailing, paddingTrailing)
                .background(.clear)
                .background() {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .rotation3DEffect(.degrees(180), axis: (x: tail.x, y: 0, z: 0))
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: tail.y, z: 0))
                    }
                }
                .clipped()
                .onTapGesture {
                    Execute.onMain {
                        SpeechManager.shared.stopSpeaking()
                        if readOnTap {
                            SpeechManager.shared.sayPhrase(text)
                        }
                    }
                    if expandOnTap {
                        //MasterDataStore.sharedDataStore.detailTitle = type.rawValue.replacing("Balloon", with: "")
                        //MasterDataStore.sharedDataStore.detailText = text
                    }
                }
                .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
        }
    }
}

#Preview {
    MangaSheechBalloonView(type: .electronic, caption: "This is a long caption that describes something in the scene... It must continue on multiple lines.")
        .environmentObject(MangaAnimation())
}
