//
//  FocusableTextPanel.swift
//  ReedWriteCycle (iOS)
//
//  Created by Kevin Mullins on 11/17/22.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage

/// A text element that can act as a virtual selected item for a UI element controlled by a gamepad.
public struct MangaFocusableTextPanel: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - title: The title of the control.
    ///   - font: The font to draw the text in.
    ///   - enabledColor: The enabled color for the text.
    ///   - disabledColor: The disabled color for the text.
    ///   - backgroundColor: The background color for the text.
    ///   - focusColor: The focused color for the text.
    ///   - borderColor: The border color for the text.
    ///   - borderWidth: The border width for the text.
    ///   - focusID: The focused id for the text.
    ///   - borderFocus: If `true`, the text element is in focus.
    ///   - isEnabled: If `true`, the element is enabled.
    ///   - isFixedFize: If `true`, the element is of a fixed size.
    ///   - boxWidth: The box width of the element.
    ///   - boxHeight: The box height of the element.
    ///   - isPixel: If `true`, render the element as a large square "pixel".
    ///   - elementInFocus: The element that is currently in focus.
    public init(title: String = "Button", font: Font = ComicFonts.TrueCrimes.ofSize(128), enabledColor: Color = MangaWorks.controlEnabledColor, disabledColor: Color = MangaWorks.controlDisabledColor, backgroundColor: Color = MangaWorks.controlBackgroundColor, focusColor: Color = MangaWorks.controlBackgroundSelectedColor, borderColor: Color = MangaWorks.controlBorderColor, borderWidth: Float = 4, focusID: String = "", borderFocus: Bool = false, isEnabled: Bool = true, isFixedFize: Bool = false, boxWidth: CGFloat = 50.0, boxHeight: CGFloat = 50.0, isPixel: Bool = false, elementInFocus: Binding<String>) {
        self.title = title
        self.font = font
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
        self.backgroundColor = backgroundColor
        self.focusColor = focusColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.focusID = focusID
        self.borderFocus = borderFocus
        self.isEnabled = isEnabled
        self.isFixedFize = isFixedFize
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.isPixel = isPixel
        self._elementInFocus = elementInFocus
    }
    
    // MARK: - Properties
    /// The title of the control.
    public var title:String = "Button"
    
    /// The font to draw the text in.
    public var font:Font = ComicFonts.TrueCrimes.ofSize(128)
    
    /// The enabled color for the text.
    public var enabledColor:Color = MangaWorks.controlEnabledColor
    
    /// The disabled color for the text.
    public var disabledColor:Color = MangaWorks.controlDisabledColor
    
    /// The background color for the text.
    public var backgroundColor:Color = MangaWorks.controlBackgroundColor
    
    /// The focused color for the text.
    public var focusColor:Color = MangaWorks.controlBackgroundSelectedColor
    
    /// The border color for the text.
    public var borderColor:Color = MangaWorks.controlBorderColor
    
    /// The border width for the text.
    public var borderWidth:Float = 4
    
    /// The focused id for the text.
    public var focusID:String = ""
    
    /// If `true`, the text element is in focus.
    public var borderFocus:Bool = false
    
    /// If `true`, the element is enabled.
    public var isEnabled:Bool = true
    
    /// If `true`, the element is of a fixed size.
    public var isFixedFize:Bool = false
    
    /// The box width of the element.
    public var boxWidth:CGFloat = 50.0
    
    /// The box height of the element.
    public var boxHeight:CGFloat = 50.0
    
    /// If `true`, render the element as a large square "pixel".
    public var isPixel:Bool = false
    
    // MARK: - Bindings
    /// The element that is currently in focus.
    @Binding public var elementInFocus:String
    
    // MARK: - Computed Properties
    /// Returns the fon color based on the enabled state.
    private var fontColor:Color {
        if isEnabled {
            return enabledColor
        } else {
            return disabledColor
        }
    }
    
    /// Returns the background color based on the element state.
    private var background:Color {
        if isPixel {
            if isEnabled {
                return enabledColor
            } else {
                return disabledColor
            }
        } else {
            if elementInFocus == focusID && !borderFocus {
                return focusColor
            } else {
                return backgroundColor
            }
        }
    }
    
    /// Returns the border color based on the element state.
    private var fontBorderColor:Color {
        if elementInFocus == focusID {
            if borderFocus {
                return focusColor
            } else {
                return borderColor
            }
        } else {
            return borderColor
        }
    }
    
    // MARK: - Main Contents
    /// The contents of the control.
    public var body: some View {
        if isFixedFize {
            Text(title)
                .font(font)
                .foregroundColor(fontColor)
                .padding(.all)
                .frame(width: boxWidth, height: boxHeight)
                .border(fontBorderColor, width: CGFloat(borderWidth))
                .background(background)
        } else {
            Text(title)
                .font(font)
                .foregroundColor(fontColor)
                .padding(.all)
                .border(fontBorderColor, width: CGFloat(borderWidth))
                .background(background)
        }
    }
}

#Preview {
    MangaFocusableTextPanel(title: "Test", elementInFocus: .constant("*"))
}
