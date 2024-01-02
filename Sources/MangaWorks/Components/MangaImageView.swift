//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/2/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage

/// Displays a detailed image view in a manga page that will float above the main panels.
public struct MangaImageView: View {
    
    // MARK: - Initializers
    /// Create a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - imageName: The name of the image to display.
    ///   - imageExtension: The extension of the image to display.
    ///   - width: The width of the image display box.
    ///   - height: The height of the image display box.
    ///   - scale: The image scale.
    ///   - hasBackground: If `true` display a background color for the image.
    ///   - background: The background color of the image box.
    ///   - shadowed: If `true`, display a shadow behind the image.
    ///   - xOffset: The X offset of the image.
    ///   - yOffset: The Y offset of the image.
    public init(imageSource: MangaWorks.Source = .appBundle, imageName: String = "", imageExtension: String = "jpg", width: Float = 400.0, height: Float = 200.0, scale: Float = 0.20, hasBackground: Bool = true, background: SwiftUI.Color = Color.black, shadowed: Bool = true, xOffset: Float = 0.0, yOffset: Float = 0.0) {
        self.imageSource = imageSource
        self.imageName = imageName
        self.imageExtension = imageExtension
        self.width = width
        self.height = height
        self.scale = scale
        self.hasBackground = hasBackground
        self.background = background
        self.shadowed = shadowed
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The name of the image to display.
    public var imageName:String = ""
    
    /// The extension of the image to display.
    public var imageExtension:String = "jpg"
    
    /// The width of the image display box.
    public var width:Float = 400.0
    
    /// The height of the image display box.
    public var height:Float = 200.0
    
    /// The image scale.
    public var scale:Float = 0.20
    
    /// If `true` display a background color for the image.
    public var hasBackground = true
    
    /// The background color of the image box.
    public var background = Color.black
    
    /// If `true`, display a shadow behind the image.
    public var shadowed:Bool = true
    
    /// The X offset of the image.
    public var xOffset:Float = 0.0
    
    /// The Y offset of the image.
    public var yOffset:Float = 0.0
    
    // MARK: - Environmental Properties
    /// The `MangaAnimation` controller for the image view.
    @EnvironmentObject private var animation:MangaAnimation
    
    // MARK: - Computed Properties
    /// Gets the background color for the image box.
    private var backgroundColor:Color {
        if hasBackground {
            return background
        } else {
            return Color.clear
        }
    }
    
    /// Gets the name for the image expanding any Grace macros in the image name.
    private var image:String {
        do {
            return try GraceRuntime.shared.expandMacros(in: imageName)
        } catch {
            Log.error(subsystem: "MangaWorks", category: "MangaImageView", "Error: \(error)")
            return imageName
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
    /// Draws the contents of the image view.
    /// - Returns: A view containing the image.
    @ViewBuilder private func contents() -> some View {
        ZStack {
            if shadowed {
                imageContents()
                    .shadow(color: .black, radius: 5, x: 10, y: 10)
            } else {
                imageContents()
            }
        }
    }
    
    /// Draws the image detail based on the source location.
    /// - Returns: Returns a view containing the image.
    @ViewBuilder private func imageContents() -> some View {
        if imageSource == .appBundle {
            ZStack {
                ScaledImageView(imageName: image, scale: scale)
            }
            .frame(width: CGFloat(width), height: CGFloat(height), alignment: .center)
            .background(backgroundColor)
            .border(backgroundColor, width: 4.0)
            .clipped()
            .allowsHitTesting(false)
            .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
        } else {
            ZStack {
                ScaledImageView(imageURL: MangaWorks.urlTo(resource: image, withExtension: imageExtension), scale: scale)
            }
            .frame(width: CGFloat(width), height: CGFloat(height), alignment: .center)
            .background(backgroundColor)
            .border(backgroundColor, width: 4.0)
            .clipped()
            .allowsHitTesting(false)
            .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
        }
    }
}

#Preview {
    MangaImageView(imageSource: .packageBundle, imageName: "LandscapeDesktop")
        .environmentObject(MangaAnimation())
}
