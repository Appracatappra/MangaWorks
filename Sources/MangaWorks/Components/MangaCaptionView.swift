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

/// Displays the contents of a caption box in a manga page.
public struct MangaCaptionView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - caption: The caption to display in the caption box.
    ///   - font: The font to display the caption in.
    ///   - fontSize: The caption font size.
    ///   - fontColor: The caption font color.
    ///   - backgroundColor: The caption background color.
    ///   - boxWidth: The caption box width.
    ///   - xOffset: The caption X offset.
    ///   - yOffset: The caption Y offset.
    public init(caption: String, font: ComicFonts = .KomikaTight, fontSize: Float = 24, fontColor: Color = Color.black, backgroundColor: Color = Color.white, boxWidth: Float = 200.0, xOffset: Float = 0.0, yOffset: Float = 0.0) {
        self.caption = caption
        self.font = font
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.boxWidth = boxWidth
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
    
    // MARK: - Properties
    /// The caption to display in the caption box.
    public var caption:String = ""
    
    /// The font to display the caption in.
    public var font:ComicFonts = .KomikaTight
    
    /// The caption font size.
    public var fontSize:Float = 24
    
    /// The caption font color.
    public var fontColor:Color = Color.black
    
    /// The caption background color.
    public var backgroundColor:Color = Color.white
    
    /// The caption box width.
    public var boxWidth:Float = 200.0
    
    /// The caption X offset.
    public var xOffset:Float = 0.0
    
    /// The caption Y offset.
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
        return MangaWorks.expandMacros(in: caption)
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
    /// Creates the body of the control.
    /// - Returns: Returns a view containing the body of the control.
    @ViewBuilder private func contents() -> some View {
        ZStack {
            Text(markdown: text)
                .font(font.ofSize(fontSize))
                .foregroundColor(fontColor)
                .padding(.all)
                .frame(width: CGFloat(boxWidth))
                .border(Color.black, width: 4)
                .background(backgroundColor)
                .clipped()
                .onTapGesture {
                    Execute.onMain {
                        SpeechManager.shared.stopSpeaking()
                        if readOnTap {
                            SpeechManager.shared.sayPhrase(text)
                        }
                    }
                    if expandOnTap {
                        MangaBook.shared.showDetails(title: "Caption", text: text)
                    }
                }
            .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
        }
    }
}

#Preview {
    MangaCaptionView(caption: "This is a long caption that describes something in the scene... It **must** continue on multiple lines.")
        .environmentObject(MangaAnimation())
}
