//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/8/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

/// Holds an overlay that can be displayed over a `MangaPageContainerView` to provide things like headers and footers.
struct MangaPageOverlayView<Content: View>: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - backgroundColor: The page background color.
    ///   - content: The contents to display in the manga page overlay.
    public init(uniqueID: String = "MangaOverlay", backgroundColor: Color  = .clear, @ViewBuilder content: @escaping () -> Content) {
        self.uniqueID = uniqueID
        self.backgroundColor = backgroundColor
        self.content = content()
        self.orientation = orientation
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "MangaOverlay"
    
    /// The page background color.
    public var backgroundColor:Color = .clear
    
    /// The contents to display in the manga page overlay.
    @ViewBuilder public var content: Content
    
    /// Holds the current device screen orientation.
    @State private var orientation = HardwareInformation.deviceOrientation
    
    // MARK: - Control Body
    /// The body of the control.
    var body: some View {
        mainContents()
            .onRotate { newOrientation in
                Execute.onMain {
                    orientation = newOrientation
                }
            }
    }
    
    // MARK: - Functions
    /// Draws the main contents of the view based on the device type and orientation.
    /// - Returns: Returns the body of the view.
    @ViewBuilder private func mainContents() -> some View {
        switch orientation {
        case .unknown:
            if HardwareInformation.screenWidth > HardwareInformation.screenHeight {
                portraitBody()
            } else {
                portraitBody()
            }
        case .landscapeLeft, .landscapeRight:
            portraitBody()
        default:
            portraitBody()
        }
    }
    
    /// Draws the portrait version of the manga page.
    /// - Returns: Returns the portrait version of the manga page.
    @ViewBuilder private func portraitBody() -> some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .overlay(container())
                .frame(width: CGFloat(HardwareInformation.screenHalfWidth), height: CGFloat(HardwareInformation.screenHeight))
            .ignoresSafeArea()
            .clipped()
        }
        .ignoresSafeArea()
        .frame(width: CGFloat(HardwareInformation.screenHalfWidth), height: CGFloat(HardwareInformation.screenHeight))
    }
    
    /// Wraps the main contents in a VStack
    /// - Returns: Returns the main contents in a VStack.
    @ViewBuilder private func container() -> some View {
        VStack {
            content
        }
    }
}

#Preview {
    MangaPageOverlayView(){
        Text("Header Area")
        
        Spacer()
        
        Text("Footer Area")
    }
}
