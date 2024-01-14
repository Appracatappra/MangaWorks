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

/// A text type button used in the touch based input UI systems.
public struct MangaTextButton: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - font: The font to draw the button in.
    ///   - enabledColor: The enabled color of the button.
    ///   - disabledColor: The displabled color of the button.
    ///   - isEnabled: If `true` the button is enabled.
    ///   - onClicked: The action to take when the button is enabled.
    public init(title: String = "", font: Font = ComicFonts.Komika.ofSize(24), enabledColor: Color = MangaWorks.controlEnabledColor, disabledColor: Color = MangaWorks.controlDisabledColor, isEnabled: Bool = true, onClicked: ContentButton.buttonAction? = nil) {
        self.title = title
        self.font = font
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
        self.isEnabled = isEnabled
        self.onClicked = onClicked
    }
    
    // MARK: Properties
    /// The title of the button.
    public var title:String = ""
    
    /// The font to draw the button in.
    public var font:Font = ComicFonts.Komika.ofSize(24)
    
    /// The enabled color of the button.
    public var enabledColor:Color = MangaWorks.controlEnabledColor
    
    /// The displabled color of the button.
    public var disabledColor:Color = MangaWorks.controlDisabledColor
    
    /// If `true` the button is enabled.
    public var isEnabled:Bool = true
    
    // MARK: - Event Handlers
    public var onClicked:ContentButton.buttonAction? = nil
    
    // MARK: - Computed Properties
    /// The font color based on the control state.
    private var fontColor: Color {
        if isEnabled {
            return enabledColor
        } else {
            return disabledColor
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        if isEnabled {
            ContentButton() {
                Text(title)
                    .font(font)
                    .foregroundColor(fontColor)
            }
        } else {
            Text(title)
                .font(font)
                .foregroundColor(fontColor)
        }
    }
}

#Preview {
    MangaTextButton()
}
