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
import SwiftUIGamepad

/// Displays the outer most container for a manga page along with a desktop and simulated iPhone for landscape views. This maintains a typical comic page contetn portrait layout in landscape mode.
public struct MangaPageContainerView<Content: View>: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - isGamepadConnected: If `true`, a gamepad is connected to this device.
    ///   - isFullPage: If `true` this is a "full page" view without the border, such as the cover or back page of the manga.
    ///   - borderColor: The page border color.
    ///   - backgroundColor: The page background color.
    ///   - content: The contents to display in the manga page.
    public init(uniqueID: String = "MangaPage", isGamepadConnected: Bool = false, isFullPage: Bool = false, borderColor: Color = .black, backgroundColor: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.uniqueID = uniqueID
        self.isGamepadConnected = isGamepadConnected
        self.isFullPage = isFullPage
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "MangaPage"
    
    /// If `true`, a gamepad is connected to this device.
    public var isGamepadConnected:Bool = false
    
    /// If `true` this is a "full page" view without the border, such as the cover or back page of the manga.
    public var isFullPage:Bool = false
    
    /// The page border color.
    public var borderColor:Color = .black
    
    /// The page background color.
    public var backgroundColor:Color = .white
    
    /// The contents to display in the manga page.
    @ViewBuilder public var content: Content 
    
    /// Holds the current device screen orientation.
    @State private var orientation = HardwareInformation.deviceOrientation
    
    // MARK: - Computed Properties
    /// Gets the inset for the comic page.
    private var insetHorizontal:CGFloat {
        if isFullPage {
            return CGFloat(0.0)
        } else if HardwareInformation.isPhone {
            return CGFloat(20.0)
        } else {
            return CGFloat(40.0)
        }
    }
    
    /// Gets the inset for the comic page.
    private var insetVertical:CGFloat {
        if isFullPage {
            return CGFloat(0.0)
        } else if HardwareInformation.isPhone {
            return CGFloat(60.0)
        } else {
            return CGFloat(40.0)
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
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
                landscapeBody()
            } else {
                portraitBody()
            }
        case .landscapeLeft, .landscapeRight:
            landscapeBody()
        default:
            portraitBody()
        }
    }
    
    /// Draws the landscape version of the manga page.
    /// - Returns: Returns the landscape version of the manga page.
    @ViewBuilder private func landscapeBody() -> some View {
        ZStack {
            // HACK: Without this hidden Button, the UI sometimes freaks out and stops responding to the gamepad events.
            Button(action: {
                // Do nothing
            }) {
                Text("Hidden")
            }
            
            // Display the desktop background.
            if let image = MangaWorks.image(name: "LandscapeDesktop", withExtension: "jpg") {
                Image(uiImage: image)
                    .resizable()
                    .ignoresSafeArea()
            }
            
            // Dashboard iPhone
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    MangaDashboardiPhoneView(isGamepadConnected: isGamepadConnected)
                        .rotationEffect(Angle(degrees: 10.0))
                }
            }
            
            // Display the page view
            portraitBody()
        }
    }
    
    /// Draws the portrait version of the manga page.
    /// - Returns: Returns the portrait version of the manga page.
    @ViewBuilder private func portraitBody() -> some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .border(borderColor, width: /*@START_MENU_TOKEN@*/4/*@END_MENU_TOKEN@*/)
                .overlay(content)
                .padding(.horizontal, insetHorizontal)
                .padding(.vertical, insetVertical)
            .ignoresSafeArea()
            .clipped()
        }
        .ignoresSafeArea()
        .background(Color.white)
        .frame(width: CGFloat(HardwareInformation.screenHalfWidth), height: CGFloat(HardwareInformation.screenHeight))
    }
}

#Preview {
    MangaPageContainerView(){
        Text("Hello World")
    }
}
