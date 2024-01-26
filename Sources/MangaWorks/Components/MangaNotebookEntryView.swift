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

/// Displays a `MangaNotbookEntry` in the apps UI.
public struct MangaNotebookEntryView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - notebookEntry: The notebook entry to display.
    ///   - titleFont: The title font.
    ///   - entryFont: The entry font.
    ///   - isSelected: If `true`, the item is selected.
    ///   - action: The action to take when the button is pressed.
    public init(imageSource: MangaWorks.Source = .appBundle, notebookEntry: MangaNotebookEntry = MangaNotebookEntry(), titleFont: ComicFonts = .KomikaBold, entryFont: ComicFonts = .KomikaTight, isSelected: Bool = false, action: ContentButton.buttonAction? = nil) {
        self.imageSource = imageSource
        self.notebookEntry = notebookEntry
        self.titleFont = titleFont
        self.entryFont = entryFont
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The notebook entry to display.
    public var notebookEntry:MangaNotebookEntry = MangaNotebookEntry()
    
    /// The title font.
    public var titleFont:ComicFonts = .KomikaBold
    
    /// The entry font.
    public var entryFont:ComicFonts = .KomikaTight
    
    /// If `true`, the item is selected.
    public var isSelected:Bool = false
    
    /// The action to take when the button is pressed.
    public var action:ContentButton.buttonAction? = nil
    
    // MARK: - Computed Properties
    /// The title of the entry.
    private var title:String {
        return MangaWorks.expandMacros(in: notebookEntry.title)
    }
    
    /// The body of the entry.
    private var entry:String {
        return MangaWorks.expandMacros(in: notebookEntry.entry)
    }
    
    /// The optional image to display for the entry.
    private var image:String {
        return MangaWorks.expandMacros(in: notebookEntry.image)
    }
    
    /// The title font size.
    private var titleSize:Float {
        if HardwareInformation.isPhone {
            return 16
        } else {
            return 24
        }
    }
    
    /// The entry body font size.
    private var entrySize:Float {
        if HardwareInformation.isPhone {
            return 14
        } else {
            return 18
        }
    }
    
    /// The card width.
    private var cardWidth:CGFloat {
        if HardwareInformation.isPhone {
            return MangaPageScreenMetrics.screenHalfWidth - 80
        } else {
            return MangaPageScreenMetrics.screenHalfWidth - 100
        }
    }
    
    /// The card height.
    private var cardHeight:CGFloat {
        switch HardwareInformation.screenWidth {
        case 375:
            return 100
        default:
            if HardwareInformation.isPhone {
                return 100
            } else {
                return 150
            }
        }
    }
    
    /// The card image width.
    private var cardImageWidth:CGFloat {
        return cardWidth * CGFloat(0.25)
    }
    
    /// The card image height.
    private var cardImageHeight:CGFloat {
        return cardHeight
    }
    
    /// The card detais with.
    private var cardDetailsWidth:CGFloat {
        return cardWidth * CGFloat(0.75)
    }
    
    /// The card background color.
    private var cardBackgroundColor:Color {
        if isSelected {
            return MangaWorks.actionSelectedBackgroundColor
        } else {
            return MangaWorks.actionBackgroundColor
        }
    }
    
    /// The card border color.
    private var cardBorderColor:Color {
        if isSelected {
            return MangaWorks.actionSelectedBorderColor
        } else {
            return MangaWorks.actionBorderColor
        }
    }
    
    /// The card font color.
    private var cardFontColor:Color {
        return MangaWorks.actionFontColor
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ContentButton(content: {contents()}, action: action)
    }
    
    // MARK: - Functions
    /// Draws the body of the notebook card.
    /// - Returns: Returns a view cotaining the body.
    @ViewBuilder private func contents() -> some View {
        HStack(spacing: 5) {
            ZStack {
                if image != "" {
                    if imageSource == .appBundle {
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardImageWidth, height: cardImageHeight)
                    } else {
                        if let rawImage = MangaWorks.image(name: image, withExtension: "jpg") {
                            Image(uiImage: rawImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardImageWidth, height: cardImageHeight)
                        }
                    }
                }
            }
            .frame(width: cardImageWidth, height: cardImageHeight)
            .background(cardBorderColor)
            .clipped()
            
            VStack(alignment: .leading) {
                Text(markdown: title)
                    .font(titleFont.ofSize(titleSize))
                    .foregroundColor(MangaWorks.actionTitleColor)
                    .multilineTextAlignment(.leading)
                
                Text(markdown: entry)
                    .font(titleFont.ofSize(entrySize))
                    .foregroundColor(cardFontColor)
                    .multilineTextAlignment(.leading)
                    .frame(width: cardDetailsWidth)
            }
            .frame(width: cardDetailsWidth, height: cardImageHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .border(cardBorderColor, width: 4)
        .background(cardBackgroundColor)
        .cornerRadius(10.0)
    }
}

#Preview {
    MangaNotebookEntryView(imageSource: .packageBundle, notebookEntry: MangaNotebookEntry(image: "Happening00", title: "My Awesome Notbook entry", entry: "This is a very long entry to test out this control and make sure that it is doing what I want it to do."), isSelected: false)
}
