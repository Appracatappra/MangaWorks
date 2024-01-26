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

/// Displays the contents of a `MangaInventoryItem` in the app's UI.
public struct MangaInventoryItemView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - item: The `MangaInventoryItem` to display the details of.
    ///   - titleFont: The title font.
    ///   - entryFont: The entry font.
    ///   - isSelected: If `true`, the item is selected.
    ///   - action: The action to take when the button is pressed.
    public init(item: MangaInventoryItem = MangaInventoryItem(), titleFont: ComicFonts = .KomikaBold, entryFont: ComicFonts = .KomikaTight, isSelected: Bool = false, action: ContentButton.buttonAction? = nil) {
        self.item = item
        self.titleFont = titleFont
        self.entryFont = entryFont
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Properties
    /// The `MangaInventoryItem` to display the details of.
    public var item:MangaInventoryItem = MangaInventoryItem()
    
    /// The title font.
    public var titleFont:ComicFonts = .KomikaBold
    
    /// The entry font.
    public var entryFont:ComicFonts = .KomikaTight
    
    /// If `true`, the item is selected.
    public var isSelected:Bool = false
    
    /// The action to take when the button is pressed.
    public var action:ContentButton.buttonAction? = nil
    
    // MARK: - Computed Properties
    /// The title of the inventory item.
    private var title:String {
        return MangaWorks.expandMacros(in: item.title)
    }
    
    /// The description of the inventory item..
    private var description:String {
        return MangaWorks.expandMacros(in:item.description)
    }
    
    /// The optional image to display for the inventory item.
    private var image:String {
        return MangaWorks.expandMacros(in: item.image)
    }
    
    /// For consumable items. return the quantity remaining.
    private var quantity:String {
        if item.isConsumable {
            return "(\(item.quantityRemaining) of \(item.initialQualtity) Remaining)"
        } else {
            return ""
        }
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
        HStack(spacing:5) {
            ZStack {
                if image != "" {
                    if item.imageSource == .appBundle {
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
                
                if quantity != "" {
                    Text(markdown: quantity)
                        .font(titleFont.ofSize(entrySize))
                        .foregroundColor(MangaWorks.actionTitleColor)
                        .multilineTextAlignment(.leading)
                }
                
                Text(markdown: description)
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
    MangaInventoryItemView(item: MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3))
}
