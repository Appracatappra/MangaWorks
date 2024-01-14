//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/14/24.
//

import SwiftUI
import SwiftUIKit
import SoundManager
import SwiftletUtilities

/// Creates a "pixel" button used in touch based symbol entry.
public struct MangaPixelButton: View {
    // MARK: - Events
    /// Handles the pixel state changing.
    public typealias buttonAction = (Bool) -> Void
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - width: The pixel width.
    ///   - height: The pixel height.
    ///   - enabledColor: The pixel enabled color.
    ///   - disabledColor: The pixel disabled color.
    ///   - action: The action to take when the pixel is clicked.
    public init(width: Double = 50.0, height: Double = 50.0, enabledColor: Color = MangaWorks.controlEnabledColor, disabledColor: Color = MangaWorks.controlDisabledColor, action: buttonAction? = nil) {
        self.width = width
        self.height = height
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
        self.action = action
    }
    
    // MARK: - Properties
    /// The pixel width.
    public var width:Double = 50.0
    
    /// The pixel height.
    public var height:Double = 50.0
    
    /// The pixel enabled color.
    public var enabledColor:Color = MangaWorks.controlEnabledColor
    
    /// The pixel disabled color.
    public var disabledColor:Color = MangaWorks.controlDisabledColor
    
    /// The action to take when the pixel is clicked.
    public var action:buttonAction? = nil
    
    // MARK: - States
    /// If `true` the pixel is turned on, else it is turned off.
    @State private var isEnabled:Bool = false
    
    // MARK: - Computed Properties
    /// The background color based on the state.
    private var backgroundColor: Color {
        if isEnabled {
            return enabledColor
        } else {
            return disabledColor
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ContentButton(content:{
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .frame(width: width, height: height)
        }, action: {
            isEnabled = !isEnabled
            if let action {
                action(isEnabled)
            }
        })
    }
}

#Preview {
    MangaPixelButton()
}
