//
//  IconButton.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 3/3/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager

/// An icon button that is used as the cetran button in a panorama view.
public struct MangaIconButton: View {
    // MARK: - vent Handlers
    /// The actoin to take when the button is pressed.
    public typealias ActionHandler = () -> Void
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - iconName: The icon to display.
    ///   - fontSize: The font size to display the icon in.
    ///   - fontColor: The color to display the icon in.
    ///   - borderColor: The border color for the icon.
    ///   - handler: The action to take when the button is pressed.
    public init(iconName: String = "arrow.up.circle.fill", fontSize: Float = 56.0, fontColor: Color = .white, borderColor: Color  = .gray, handler: ActionHandler? = nil) {
        self.iconName = iconName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.borderColor = borderColor
        self.handler = handler
    }
    
    // MARK: - Constructors
    /// The icon to display.
    public var iconName:String = "arrow.up.circle.fill"
    
    /// The font size to display the icon in.
    public var fontSize:Float = 56.0
    
    /// The color to display the icon in.
    public var fontColor:Color = .white
    
    /// The border color for the icon.
    public var borderColor:Color = .gray
    
    /// The action to take when the button is pressed.
    public var handler:ActionHandler? = nil
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        #if os(tvOS)
        ZStack {
            Image(systemName: iconName)
                .font(.system(size: CGFloat(fontSize + 2.0)))
                .foregroundColor(borderColor)
            
            Image(systemName: iconName)
                .font(.system(size: CGFloat(fontSize)))
                .foregroundColor(fontColor)
        }
        #else
        Button(action: {
            Execute.onMain {
                if let handler = handler {
                    handler()
                }
            }
        }) {
            ZStack {
                Image(systemName: iconName)
                    .font(.system(size: CGFloat(fontSize + 2.0)))
                    .foregroundColor(borderColor)
                
                Image(systemName: iconName)
                    .font(.system(size: CGFloat(fontSize)))
                    .foregroundColor(fontColor)
            }
        }
        #endif
    }
}

#Preview {
    MangaIconButton()
}
