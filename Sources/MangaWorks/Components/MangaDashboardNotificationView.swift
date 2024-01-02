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

/// Creates a notification box that is displayed on the iPhone image in the landscaped view.
public struct MangaDashboardNotificationView: View {
    
    // MARK: - Initializers
    /// Create a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - iconName: The icon to display for the notification.
    ///   - title: The title of the notification.
    ///   - description: The description of the notification.
    ///   - boxWidth: The notification box width.
    ///   - boxHeight: The notification box height.
    ///   - fontAsjustment: The amount to adjust the font size by.
    public init(iconName: String = "note.text", title: String = "", description: String = "", boxWidth: CGFloat = 300, boxHeight: CGFloat = 100, fontAsjustment: CGFloat = 0.0) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.fontAsjustment = fontAsjustment
    }
    
    // MARK: - Properties
    /// The icon to display for the notification.
    public var iconName:String = "note.text"
    
    /// The title of the notification.
    public var title:String = ""
    
    /// The description of the notification.
    public var description:String = ""
    
    /// The notification box width.
    public var boxWidth:CGFloat = 300
    
    /// The notification box height.
    public var boxHeight:CGFloat = 100
    
    /// The amount to adjust the font size by.
    public var fontAsjustment:CGFloat = 0.0
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        RoundedRectangle(cornerRadius: 20.0)
            .fill(Color(fromHex: "FFFFFFB0")!)
            .background(.clear)
            .frame(width: boxWidth, height: boxHeight)
            .overlay {
                HStack(spacing: 5.0) {
                    Image(systemName: iconName)
                        .font(.system(size: 40 - fontAsjustment))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(markdown: title)
                                .font(.system(size: 14 - fontAsjustment))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        Text(description)
                            .font(.system(size: 14 - fontAsjustment))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width: boxWidth - 100.0)
                    }
                }
            }
    }
}

#Preview {
    MangaDashboardNotificationView(title: "**Title**", description: "This is a sample notification body.")
}
