// The Swift Programming Language
// https://docs.swift.org/swift-book
// https://dev.jeremygale.com/swiftui-how-to-use-custom-fonts-and-images-in-a-swift-package-cl0k9bv52013h6bnvhw76alid

import Foundation
import SwiftUI
import SwiftletUtilities
import LogManager
import GraceLanguage
import SoundManager

/// A utility for working with resources stored inside of this Swift Package.
open class MangaWorks {
    
    // MARK: - Enumerations
    /// Defines the source of a file.
    public enum Source: Int {
        /// The file is from the App's Bundle.
        case appBundle = 0
        
        /// The file is from the Swift Package's Bundle.
        case packageBundle
        
        // MARK: - Functions
        /// Gets the value from an `appBundle` and defaults to `left` if the conversion is invalid.
        /// - Parameter value: The value holding the Int to convert.
        public mutating func from(_ value:Int) {
            if let enumeration = Source(rawValue: value) {
                self = enumeration
            } else {
                self = .appBundle
            }
        }
    }
    
    // MARK: Static Properties
    /// The default font color for About Page Heder Items.
    public nonisolated(unsafe) static var aboutHeaderColor:Color = .white
    
    /// The default font color for About Page Body Items.
    public nonisolated(unsafe) static var aboutBodyColor:Color = .white
    
    /// The default font color for About Page Body Icon.
    public nonisolated(unsafe) static var aboutIconColor:Color = .white
    
    /// The default font color for Manga Actions.
    public nonisolated(unsafe) static var actionFontColor:Color = .white
    
    /// The default action title color.
    public nonisolated(unsafe) static var actionTitleColor:Color = Color(fromHex: "#1F0A39")!
    
    /// The default background color for Manga Actions.
    public nonisolated(unsafe) static var actionBackgroundColor:Color = Color(fromHex: "#8D52AF")!
    
    /// The default selected color for Manga Actions.
    public nonisolated(unsafe) static var actionSelectedBackgroundColor:Color = Color(fromHex: "#EB244F")!
    
    /// The default border color for Manga Actions.
    public nonisolated(unsafe) static var actionBorderColor:Color = Color(fromHex: "#533169")!
    
    /// The default selected border color for Manga Actions.
    public nonisolated(unsafe) static var actionSelectedBorderColor:Color = .white
    
    /// The default foreground color for Manga Actions.
    public nonisolated(unsafe) static var actionForegroundColor:Color = Color(fromHex: "#8D52AF")!
    
    /// The default highlight color for Manga Actions.
    public nonisolated(unsafe) static var actionHighlightColor:Color = Color(fromHex: "#EB004F")!
    
    /// The default menu gradient colors.
    public nonisolated(unsafe) static var menuGradient:[Color] = [Color(fromHex: "#502670")!, Color(fromHex: "#8D43C3")!, Color(fromHex: "#F88C00")!]
    
    /// The default border on word art text.
    public nonisolated(unsafe) static var wordArtBorderColor:Color = .black
    
    /// The default menu background color.
    public nonisolated(unsafe) static var menuBackgroundColor: Color = Color(fromHex: "#290541")!
    
    /// The default control button gradient colors.
    public nonisolated(unsafe) static var controlButtonGradient:[Color] = [Color(fromHex: "#533169")!, Color(fromHex: "#533169")!]
    
    /// The default menu selected gradient colors.
    public nonisolated(unsafe) static var menuSelectedGradient:[Color] = [Color(fromHex: "#EB004F")!, Color(fromHex: "#EB004F")!]
    
    /// The default control enabled  color.
    public nonisolated(unsafe) static var controlEnabledColor: Color = Color(fromHex: "#EB004F")!
    
    /// The default control disabled color.
    public nonisolated(unsafe) static var controlDisabledColor: Color = .gray
    
    /// The default control foreground color.
    public nonisolated(unsafe) static var controlForegroundColor: Color = Color(fromHex: "#8D52AF")!
    
    /// The default control background color.
    public nonisolated(unsafe) static var controlBackgroundColor: Color = Color(fromHex: "#8D52AF")!
    
    /// The default control selected background color.
    public nonisolated(unsafe) static var controlBackgroundSelectedColor: Color = Color(fromHex: "#EB244F")!
    
    /// The default control border color.
    public nonisolated(unsafe) static var controlBorderColor: Color = Color(fromHex: "#533169")!
    
    /// The default conversation foreground color.
    public nonisolated(unsafe) static var conversationForegroundColor: Color = .white
    
    /// The default conversation background color.
    public nonisolated(unsafe) static var conversationBackgroundColor: Color = .black.opacity(0.68)
    
    /// The default avatar image used in input screens.
    public nonisolated(unsafe) static var inputAvatarImage:String = ""
    
    /// The default background image used in input controls.
    public nonisolated(unsafe) static var inputBackgroundImage:String = ""
    
    // MARK: - Static Functions
    /// Gets the path to the requested resource stored in the Swift Package's Bundle.
    /// - Parameters:
    ///   - resource: The name of the resource to locate.
    ///   - ofType: The type/extension of the resource to locate.
    /// - Returns: The path to the resource or `nil` if not found.
    public static func pathTo(resource:String?, ofType:String? = nil) -> String?  {
        let path = Bundle.module.path(forResource: resource, ofType: ofType)
        return path
    }
    
    /// Gets the url to the requested resource stored in the Swift Package's Bundle.
    /// - Parameters:
    ///   - resource: The name of the resource to locate.
    ///   - withExtension: The extension of the resource to locate.
    /// - Returns: The path to the resource or `nil` if not found.
    public static func urlTo(resource:String?, withExtension:String? = nil) -> URL? {
        let url = Bundle.module.url(forResource: resource, withExtension: withExtension)
        return url
    }
    
    /// Registers the given font with the Core Text Font Manager so that it can be used in a SwiftUI `View`.
    /// - Parameter name: The name of the font to register.
    public static func registerFont(name:String) {
        guard let url = urlTo(resource: name) else {
            Log.error(subsystem: "MangaWorks", category: "Fonts", "Unable to find font: \(name)")
            return
        }
        
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
    
    /// Returns a `UIImage` from the package's bundle.
    /// - Parameters:
    ///   - name: The name of the image file to return.
    ///   - withExtension: The extension of the file to return.
    ///   - scale: The size of the resulting image.
    /// - Returns: Returns the `UIImage` if found, else returns `nil`.
    public static func image(name:String, withExtension:String = "png", scale:CGFloat = 1.0) -> UIImage? {
        let url = MangaWorks.urlTo(resource: name, withExtension: withExtension)
        return UIImage.scaledImage(bundleURL: url, scale: scale)
    }
    
    /// Returns a `UIImage` from the package's bundle.
    /// - Parameters:
    ///   - name: The name of the image file to return.
    ///   - withExtension: The extension of the file to return.
    /// - Returns: Returns the `UIImage` if found, else returns `nil`.
    public static func rawImage(name:String, withExtension: String? = nil) -> UIImage? {
        if let path = MangaWorks.pathTo(resource: name, ofType: withExtension) {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    /// Evaluates the given condition written as a Grace Language macro or script.
    /// - Parameter condition: The script to evaluate.
    /// - Returns: Returns the result of the condition or `true` if no condition is provided.
    public static func evaluateCondition(_ condition:String) -> Bool {
        
        // No condition presented, assume true.
        guard condition != "" else {
            return true
        }
        
        // Try to evaluate the condition.
        do {
            // Get the result of the condition.
            if let result = try GraceRuntime.shared.evaluate(script: condition) {
                // Return the result to the caller.
                return result.bool
            } else {
                // Unable to evaluate.
                return false
            }
        } catch {
            // An error occurred, return false.
            Log.error(subsystem: "MangaWorks", category: "evaluateCondition", "Error: \(error)")
            return false
        }
    }
    
    /// Expands the macros in the text field.
    /// - Parameter text: The text to expand macros in.
    /// - Returns: The text with any Grace Macros expanded.
    public static func expandMacros(in text:String) -> String {
        do {
            return try GraceRuntime.shared.expandMacros(in: text)
        } catch {
            Log.error(subsystem: "MangaWorks", category: "ExpandMacros", "Error: \(error)")
            return text
        }
    }
    
    /// Runs the given Grace Language Script and reports an errors that occur. If the script does not contain a `main` function definition, one will be added before the script is executed.
    /// - Parameter script: The Grace Language Script to execute.
    public static func runGraceScript(_ script:String) {
        
        // Ensure there is a script to run.
        guard script != "" else {
            return
        }
        
        Execute.onMain {
            do {
                if script.contains("main {") || script.contains("main{") {
                    try GraceRuntime.shared.run(program: script)
                } else {
                    try GraceRuntime.shared.run(script: script)
                }
            } catch {
                Log.error(subsystem: "MangaWorks", category: "runGraceScript", "Error: \(error)")
            }
        }
    }
    
    /// Registers unctions with the Grace Language so they are available in MangaWorks Grace Scripts
    public static func registerGraceFunctions() {
        
        // Register all the required scripts
        Task {@MainActor in
            SoundManager.registerGraceFunctions()
            MangaStateManager.registerGraceFunctions()
            MangaBook.registerGraceFunctions()
            MangaChapter.registerGraceFunctions()
        }
    }
}
