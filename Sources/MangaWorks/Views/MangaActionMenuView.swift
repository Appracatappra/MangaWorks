//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/10/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

// MARK: - Computed Properties
/// Gets the inset for the comic page.
public struct MangaActionMenuView: View {
    // MARK: - Event Handlers
    public typealias HandleClose = () -> Void
    
    // MARK: - Initializers
    
    // MARK: - Properties
    /// The unique ID of the container used to tie in gamepad support.
    public var uniqueID:String = "ActionMenu"
    
    public var isGamepadConnected:Bool = false
    
    public var onClose:HandleClose? = nil
    
    // MARK: - Computed Properties
    /// Returns the menu padding based on the device the app is running on.
    private var menuPadding:CGFloat {
        if HardwareInformation.isPhone {
            return 5
        } else {
            return 0
        }
    }
    
    /// Returns the menu font size based on the device the app is running on.
    private var menuSize:Float {
        switch HardwareInformation.screenWidth {
        case 744:
            return 27
        case 1024:
            return 42
        default:
            if HardwareInformation.isPhone {
                return 18
            } else if HardwareInformation.isPad {
                switch HardwareInformation.deviceOrientation {
                case .landscapeLeft, .landscapeRight:
                    return 28
                default:
                    return 34
                }
            } else {
                return 34
            }
        }
    }
    
    /// The card width.
    private var cardWidth:Float {
        return Float(HardwareInformation.screenHalfWidth - 100)
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        MangaPageOverlayView(uniqueID: uniqueID, backgroundColor: MangaWorks.menuBackgroundColor) {
            pageContents()
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Functions
    @ViewBuilder func pageContents() -> some View {
        VStack {
            Text(markdown: "Actions")
                .font(ComicFonts.Troika.ofSize(48))
                .foregroundColor(MangaWorks.actionFontColor)
                .padding(.top)
            
            // The right side menus.
            if isGamepadConnected {
                GamepadMenuView(id: "InventoryItems", alignment: .trailing, menu: buildGamepadMenu(), fontName: ComicFonts.Komika.rawValue, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, selectedColors: MangaWorks.menuSelectedGradient, shadowed: false, maxEntries: 8, boxWidth: cardWidth, padding: 0)
            } else {
                touchMenu()
            }
            
            Spacer()
        }
        .frame(width: MangaPageScreenMetrics.screenHalfWidth, height: MangaPageScreenMetrics.screenHeight)
        .ignoresSafeArea()
    }
    
    /// Creates the right side touch menu for the cover.
    /// - Returns: Returns a view containing the right side touch menu.
    @ViewBuilder func touchMenu() -> some View {
        ScrollView {
            VStack {
                ForEach(MangaBook.shared.actionMenuItems) {action in
                    if MangaWorks.evaluateCondition(action.condition) {
                        MangaButton(title: action.text, font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                            MangaWorks.runGraceScript(action.excute)
                            if let onClose {
                                onClose()
                            }
                        }
                        .padding(.bottom, menuPadding)
                    }
                }
                
                MangaButton(title: "Close Actions", font: ComicFonts.stormfaze, fontSize: menuSize, gradientColors: MangaWorks.menuGradient, shadowed: true) {
                    if let onClose {
                        onClose()
                    }
                }
                .padding(.bottom, menuPadding)
            }
        }
    }
    
    /// Creates the menu for an attached gamepad.
    /// - Returns: Returns a `GamepadMenu` containing all of the menu items.
    func buildGamepadMenu() -> GamepadMenu {
        
        let menu = GamepadMenu()
        
        for action in MangaBook.shared.actionMenuItems {
            if MangaWorks.evaluateCondition(action.condition) {
                menu.addItem(title: action.text) {
                    MangaWorks.runGraceScript(action.excute)
                    if let onClose {
                        onClose()
                    }
                }
            }
        }
        
        menu.addItem(title: "Close Actions") {
            if let onClose {
                onClose()
            }
        }
        
        return menu
    }
}

#Preview {
    MangaActionMenuView()
}
