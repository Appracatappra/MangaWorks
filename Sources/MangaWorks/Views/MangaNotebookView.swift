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

/// Displays the contents of a `MangaNotebook`.
struct MangaNotebookView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - imageSource: Defines the source of the image.
    ///   - uniqueID: The unique ID of the container used to tie in gamepad support.
    ///   - entries: A collection of `MangaNotebookEntry` objects to display.
    ///   - backgroundColor: The background color of the page.
    ///   - isGamepadRequired: If `true`, a gamepad is required to run the app.
    ///   - isAttachedToGameCenter: If `true`, the app is attached to Game Center.
    public init(imageSource: MangaWorks.Source = .appBundle, uniqueID: String = "Notebook", entries: [MangaNotebookEntry] = [], backgroundColor: Color = .white, isGamepadRequired: Bool = false, isAttachedToGameCenter: Bool = false) {
        self.imageSource = imageSource
        self.uniqueID = uniqueID
        self.entries = entries
        self.backgroundColor = backgroundColor
        self.isGamepadRequired = isGamepadRequired
        self.isAttachedToGameCenter = isAttachedToGameCenter
    }
    
    // MARK: - Properties
    /// Defines the source of the image.
    public var imageSource:MangaWorks.Source = .appBundle
    
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "Notebook"
    
    /// A collection of `MangaNotebookEntry` objects to display.
    public var entries:[MangaNotebookEntry] = []
    
    /// The background color of the page.
    public var backgroundColor: Color = .white
    
    /// If `true`, a gamepad is required to run the app.
    public var isGamepadRequired:Bool = false
    
    /// If `true`, the app is attached to Game Center.
    public var isAttachedToGameCenter:Bool = false
    
    // MARK: - States
    /// If `true`, show the gamepad help overlay.
    @State private var showGamepadHelp:Bool = false
    
    /// If `true`, a gamepad is connected to the device the app is running on.
    @State private var isGamepadConnected:Bool = false
    
    /// If `true`, a notes details are being shown.
    @State private var isShowingDetails:Bool = false
    
    /// Holds the notebook entry that is currently being displayed.
    @State private var selectedNote:MangaNotebookEntry? = nil
    
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
    
    /// Gets the inset for the comic page.
    private var inset:CGFloat {
        if HardwareInformation.isPhone {
            return CGFloat(80.0)
        } else {
            return CGFloat(100.0)
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    var body: some View {
        ZStack {
            MangaPageContainerView(uniqueID: uniqueID, isGamepadConnected: isGamepadConnected, isFullPage: false, backgroundColor: backgroundColor) {
                pageBodyContents()
            }
            
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
                isShowingDetails = false
                selectedNote = nil
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
            // The right side menus.
            if isGamepadConnected {
                GamepadMenuView(id: "NotebookItems", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.Komika.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 6, boxWidth: cardWidth, padding: 0)
            } else {
                touchMenu()
            }
        }
    }
    
    /// Draws the header and footer overlay contents.
    /// - Returns: Returns a view containing the header and footer.
    @ViewBuilder func pageOverlayContents() -> some View {
        VStack {
            pageheader()
            
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
                    selectedNote = nil
                }
                .padding(.leading)
            } else {
                MangaButton(title: "Back", fontSize: MangaPageScreenMetrics.controlButtonFontSize) {
                    MangaBook.shared.displayPage(id: "<<")
                }
                .padding(.leading)
            }
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    /// Draws the page footer.
    /// - Returns: Returns a view containing the page footer.
    @ViewBuilder func pageFooter() -> some View {
        HStack {
            
            Text("Notebook")
                .font(ComicFonts.Komika.ofSize(footerTextSize))
                .foregroundColor(.black)
                .padding(.leading)
            
            Spacer()
            
            Text("Notes: \(entries.count)")
                .font(ComicFonts.Komika.ofSize(footerTextSize))
                .foregroundColor(.black)
                .padding(.trailing)
        }
        .padding(.bottom, 10)
    }
    
    /// Draws the touch menu of notebook entries.
    /// - Returns: Returns a view containing the touch menu items.
    @ViewBuilder func touchMenu() -> some View {
        ScrollView {
            VStack {
                ForEach(entries, id: \.notebookID) { entry in
                    MangaNotebookEntryView(notebookEntry: entry) {
                        selectedNote = entry
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
            let text = "\(entry.title): \(entry.entry)"
            menu.addItem(title: text) {
                selectedNote = entry
                isShowingDetails = true
            }
        }
        
        
        return menu
    }
    
    /// Draws a view containing the selected note's details.
    /// - Returns: Returns a view containing the note's details.
    @ViewBuilder func noteDetails() -> some View {
        VStack {
            if let note = selectedNote {
                if note.image != "" {
                    if imageSource == .appBundle {
                        ScaledImageView(imageName: note.image, scale: 0.4)
                    } else {
                        ScaledImageView(imageURL: MangaWorks.urlTo(resource: note.image, withExtension: "jpg"), scale: 0.4)
                    }
                }
                
                Text(markdown: MangaWorks.expandMacros(in: note.title))
                    .font(ComicFonts.KomikaBold.ofSize(32))
                    .foregroundColor(MangaWorks.actionTitleColor)
                
                Text(markdown: MangaWorks.expandMacros(in: note.entry))
                    .font(ComicFonts.KomikaBold.ofSize(18))
                    .foregroundColor(MangaWorks.actionFontColor)
            }
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth - inset, height: MangaPageScreenMetrics.screenHeight - inset)
        .background(MangaWorks.actionBackgroundColor)
    }
}

#Preview {
    MangaNotebookView(imageSource: .packageBundle, entries: [MangaNotebookEntry(notebookID: "01", image: "Happening00", title: "Note #01", entry: "It was the best of times, it was the worst of times."), MangaNotebookEntry(notebookID: "02", title: "Note #02", entry: "It was the best of times, it was the worst of times."), MangaNotebookEntry(notebookID: "03", title: "Note #03", entry: "It was the best of times, it was the worst of times."), MangaNotebookEntry(notebookID: "04", title: "Note #04", entry: "It was the best of times, it was the worst of times."), MangaNotebookEntry(notebookID: "05", title: "Note #05", entry: "It was the best of times, it was the worst of times."), MangaNotebookEntry(notebookID: "06", title: "Note #06", entry: "It was the best of times, it was the worst of times.")])
}
