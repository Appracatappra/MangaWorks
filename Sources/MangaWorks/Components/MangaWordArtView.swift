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
import LogManager

/// Displays a Word Art element at for a Manga Page.
public struct MangaWordArtView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - title: The word art to display.
    ///   - font: The font to display the word art in.
    ///   - fontSize: The font size to diplay the word art in.
    ///   - gradientColors: The gradient colors for the word art.
    ///   - rotationDegrees: The rotation degrees for the word art gradient.
    ///   - shadowed: If `true`, display a shadow for the word art.
    ///   - xOffset: The X offset for the word art.
    ///   - yOffset: The Y offset for the word art.
    public init(title: String, font: ComicFonts = .TrueCrimes, fontSize: Float = 128, gradientColors: [Color] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red], rotationDegrees: Double = 0, shadowed: Bool = true, xOffset: Float = 0.0, yOffset: Float = 0.0) {
        self.title = title
        self.font = font
        self.fontSize = fontSize
        self.gradientColors = gradientColors
        self.rotationDegrees = rotationDegrees
        self.shadowed = shadowed
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
    
    // MARK: - Properties
    /// The word art to display.
    public var title:String = ""
    
    /// The font to display the word art in.
    public var font:ComicFonts = .TrueCrimes
    
    /// The font size to diplay the word art in.
    public var fontSize:Float = 128
    
    /// The gradient colors for the word art.
    public var gradientColors:[Color] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red]
    
    /// The rotation degrees for the word art gradient.
    public var rotationDegrees:Double = 0
    
    /// If `true`, display a shadow for the word art.
    public var shadowed:Bool = true
    
    /// The X offset for the word art.
    public var xOffset:Float = 0.0
    
    /// The Y offset for the word art.
    public var yOffset:Float = 0.0
    
    // MARK: - Environmental Properties
    /// The `MangaAnimation` controller for the control.
    @EnvironmentObject private var animation:MangaAnimation
    
    // MARK: - Computed Properties
    /// The expanded text for the word art.
    private var text:String {
        do {
            return try GraceRuntime.shared.expandMacros(in: title)
        } catch {
            Log.error(subsystem: "MangaWorks", category: "MangaWordArtView", "Error: \(error)")
            return title
        }
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
    /// Draws the body of the control.
    /// - Returns: Returns a view containing the body of the control.
    @ViewBuilder private func contents() -> some View {
        ZStack {
            if shadowed {
                Text(markdown: text)
                    .font(font.ofSize(fontSize))
                    .foregroundStyle(.linearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom))
                    .rotationEffect(Angle(degrees: rotationDegrees))
                    .shadow(color: .black, radius: 5, x: 10, y: 10)
                    .allowsHitTesting(false)
                    .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
            } else {
                Text(markdown: text)
                    .font(font.ofSize(fontSize))
                    .foregroundStyle(.linearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom))
                    .rotationEffect(Angle(degrees: rotationDegrees))
                    .allowsHitTesting(false)
                    .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
            }
        }
    }
}

#Preview {
    MangaWordArtView(title: "Zaaaap!")
        .environmentObject(MangaAnimation())
}
