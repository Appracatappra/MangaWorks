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

/// Displays all of the inventory items in the player's inventory.
public struct MangaInventoryView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - entries: A collection of `MangaInventoryItem` objects to display.
    ///   - backgroundColor: The background color of the page.
    ///   - noItemsImage: The image to show if the player isn't carrying any items.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(imageSource: MangaWorks.Source = .appBundle, uniqueID: String = "Inventory", entries: [MangaInventoryItem] = [], backgroundColor: Color = .white, noItemsImage:String = "", isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.imageSource = imageSource
        self.uniqueID = uniqueID
        self.entries = entries
        self.backgroundColor = backgroundColor
        self.noItemsImage = noItemsImage
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "Inventory"
    
    /// A collection of `MangaInventoryItem` objects to display.
    public var entries:[MangaInventoryItem] = []
    
    /// The background color of the page.
    public var backgroundColor: Color = .white
    
    /// The image to show if the player isn't carrying any items.
    public var noItemsImage:String = ""
    
    /// If `true`, a gamepad is required to run the app.
    public var isGamepadRequired:Bool = false
    
    /// If `true`, the app is attached to Game Center.
    public var isAttachedToGameCenter:Bool = false
    
    // MARK: - States
    /// If `true`, show the gamepad help overlay.
    @State private var showGamepadHelp:Bool = false
    
    /// If `true`, a gamepad is connected to the device the app is running on.
    @State private var isGamepadConnected:Bool = false
    
    /// If `true`, an item's details are being shown.
    @State private var isShowingDetails:Bool = false
    
    /// Holds the inventory item that is currently being displayed.
    @State private var selectedItem:MangaInventoryItem? = nil
    
    // MARK: - Computed Properties
    /// Returns the size of the footer text.
    private var footerTextSize:Float {
        if HardwareInformation.isPhone {
            return 10
        } else {
            return 12
        }
    }
    
    /// Returns the menu font size based on the device the app is running on.
    private var menuSize:Float {
        switch HardwareInformation.screenWidth {
        case 744:
            return 24
        case 1024:
            return 24
        default:
            if HardwareInformation.isPhone {
                return 18
            } else if HardwareInformation.isPad {
                switch HardwareInformation.deviceOrientation {
                case .landscapeLeft, .landscapeRight:
                    return 24
                default:
                    return 24
                }
            } else {
                return 24
            }
        }
    }
    
    /// The card width.
    private var cardWidth:Float {
        return Float(HardwareInformation.screenHalfWidth - 100)
    }
    
    /// Gets the width of a footer column.
    private var footerColumnWidth:CGFloat {
        return MangaPageScreenMetrics.screenHalfWidth / 3.0
    }
    
    /// Gets the inset for the comic page.
    private var insetHorizontal:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(20.0)
        } else {
            return CGFloat(90.0)
        }
    }
    
    /// Gets the inset for the comic page.
    private var insetVertical:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(100.0)
        } else {
            return CGFloat(90.0)
        }
    }
    
    /// Defines the header padding based on the device.
    private var headerPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 30.0
        } else {
            return 20.0
        }
    }
    
    /// Defines the footer padding based on the device.
    private var footerPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 40.0
        } else {
            return 10.0
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, backgroundColor: backgroundColor) {
                pageBodyContents()
            }
            #if os(iOS)
            .statusBar(hidden: true)
            #endif
            
            MangaPageOverlayView(uniqueID: uniqueID) {
                pageOverlayContents()
            }
            
            // Display gamepad help
            if showGamepadHelp {
                GamepadHelpOverlay()
            }
            
            // Display gamepad required.
            if isGamepadRequired && !isGamepadConnected {
                GamepadRequiredOverlay()
            }
        }
        .onAppear {
            connectGamepad(viewID: uniqueID, handler: { controller, gamepadInfo in
                isGamepadConnected = true
                buttonAUsage(viewID: uniqueID, "Show or hide **Gamepad Help**.")
                buttonBUsage(viewID: uniqueID, "Close an open note details.")
                buttonYUsage(viewID: uniqueID, "Use the selected item.")
            })
        }
        .onDisappear {
            disconnectGamepad(viewID: uniqueID)
        }
        .onGampadAppBecomingActive(viewID: uniqueID) {
            reconnectGamepad()
        }
        .onGamepadDisconnected(viewID: uniqueID) { controller, gamepadInfo in
            isGamepadConnected = false
        }
        .onGamepadButtonA(viewID: uniqueID) { isPressed in
            if isPressed {
                showGamepadHelp = !showGamepadHelp
            }
        }
        .onGamepadButtonB(viewID: uniqueID) { isPressed in
            if isPressed {
                if isShowingDetails {
                    isShowingDetails = false
                    selectedItem = nil
                } else {
                    MangaBook.shared.returnToLastView()
                }
            }
        }
        .onGamepadButtonY(viewID: uniqueID) { isPressed in
            if isPressed {
                if let item = selectedItem {
                    if item.onUse != "" {
                        MangaWorks.runGraceScript(item.onUse)
                    }
                }
            }
        }
        #if os(tvOS)
        .onMoveCommand { direction in
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Move: \(direction)")
        }
        .onExitCommand {
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Exit")
        }
        .onPlayPauseCommand {
            //Debug.info(subsystem: "MangaPageContainerView", category: "mainContents", "AppleTV Play/Pause")
        }
        #endif
    }
    
    // MARK: - Functions
    /// Creates the main body of the cover.
    /// - Returns: Returns a view representing the body of the cover.
    @ViewBuilder func pageBodyContents() -> some View {
        if isShowingDetails {
            noteDetails()
        } else {
            // Anything to display?
            if entries.count == 0 {
                if noItemsImage != "" {
                    Image(noItemsImage)
                        .resizable()
                        .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
                }
            } else {
                // The right side menus.
                if isGamepadConnected {
                    GamepadMenuView(id: "InventoryItems", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.Komika.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 6, boxWidth: cardWidth, padding: 0)
                } else {
                    touchMenu()
                }
            }
        }
    }
    
    /// Draws the header and footer overlay contents.
    /// - Returns: Returns a view containing the header and footer.
    @ViewBuilder func pageOverlayContents() -> some View {
        VStack {
            if isGamepadConnected {
                pageheaderGamepad()
            } else {
                pageheader()
            }
            
            Spacer()
            
            pageFooter()
        }
    }
    
    /// Draws the page header.
    /// - Returns: Returns a view containing the page header.
    @ViewBuilder func pageheader() -> some View {
        HStack {
            if isShowingDetails {
                MangaButton(title: "Close", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                    isShowingDetails = false
                    selectedItem = nil
                }
                .padding(.leading)
            } else {
                MangaButton(title: "Back", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                    MangaBook.shared.returnToLastView()
                }
                .padding(.leading)
            }
            
            Spacer()
            
            if isShowingDetails {
                if let item = selectedItem {
                    if item.onUse != "" {
                        MangaButton(title: "Use", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                            MangaWorks.runGraceScript(item.onUse)
                        }
                        .padding(.trailing)
                    }
                }
            }
        }
        .padding(.top, headerPadding)
    }
    
    /// Renders the page header when a gamepdais attached.
    /// - Returns: Returs a view containing the gamepad header.
    @ViewBuilder func pageheaderGamepad() -> some View {
        HStack {
            GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonBImage, title: (isShowingDetails) ? "Close" : "Back", scale: MangaPageScreenMetrics.controlButtonScale)
                .padding(.leading)
            
            Spacer()
            
            if let item = selectedItem {
                if item.onUse != "" {
                    GamepadControlTip(iconName: GamepadManager.gamepadOne.gampadInfo.buttonYImage, title: "Use", scale: MangaPageScreenMetrics.controlButtonScale)
                        .padding(.leading)
                }
            }
        }
        .padding(.top, headerPadding)
    }
    
    /// Draws the page footer.
    /// - Returns: Returns a view containing the page footer.
    @ViewBuilder func pageFooter() -> some View {
        HStack {
            
            ZStack {
                Text("Inventory")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.leading)
            }
            .frame(width: footerColumnWidth)
            
            Spacer()
            
            ZStack {
                Text("Items: \(entries.count)")
                    .font(ComicFonts.Komika.ofSize(footerTextSize))
                    .foregroundColor(.black)
                    .padding(.trailing)
            }
            .frame(width: footerColumnWidth)
        }
        .padding(.bottom, footerPadding)
    }
    
    /// Draws the touch menu of notebook entries.
    /// - Returns: Returns a view containing the touch menu items.
    @ViewBuilder func touchMenu() -> some View {
        ScrollView {
            VStack {
                ForEach(entries) { item in
                    MangaInventoryItemView(item: item) {
                        selectedItem = item
                        isShowingDetails = true
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    /// Creates the menu for an attached gamepad.
    /// - Returns: Returns a `GamepadMenu` containing all of the menu items.
    func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu(style: .cards)
        
        for entry in entries {
            let text = "\(entry.title): \(entry.description)"
            menu.addItem(title: text) {
                selectedItem = entry
                isShowingDetails = true
            }
        }
        
        
        return menu
    }
    
    /// Draws a view containing the selected note's details.
    /// - Returns: Returns a view containing the note's details.
    @ViewBuilder func noteDetails() -> some View {
        VStack {
            if let item = selectedItem {
                if item.image != "" {
                    if item.imageSource == .appBundle {
                        ScaledImageView(imageName: item.image, scale: 0.4)
                    } else {
                        ScaledImageView(imageURL: MangaWorks.urlTo(resource: item.image, withExtension: "jpg"), scale: 0.4)
                    }
                }
                
                Text(markdown: MangaWorks.expandMacros(in: item.title))
                    .font(ComicFonts.KomikaBold.ofSize(32))
                    .foregroundColor(MangaWorks.actionTitleColor)
                
                if item.isConsumable {
                    Text(markdown: "(\(item.quantityRemaining) of \(item.initialQualtity) Remaining)")
                        .font(ComicFonts.KomikaBold.ofSize(18))
                        .foregroundColor(MangaWorks.actionTitleColor)
                }
                
                Text(markdown: MangaWorks.expandMacros(in: item.description))
                    .font(ComicFonts.KomikaBold.ofSize(18))
                    .foregroundColor(MangaWorks.actionFontColor)
            }
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth - insetHorizontal, height: MangaPageScreenMetrics.screenHeight - insetVertical)
        .background(MangaWorks.actionBackgroundColor)
    }
}

#Preview {
    MangaInventoryView(entries: [MangaInventoryItem(imageSource: .packageBundle, id: "01", image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3, onUse: "//Do Something"), MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3), MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3), MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3), MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3), MangaInventoryItem(imageSource: .packageBundle, image: "Happening00", title: "Happening Card", description: "This is a card that the user can find within the game.", isConsumable: true, initialQualtity: 3)])
}
