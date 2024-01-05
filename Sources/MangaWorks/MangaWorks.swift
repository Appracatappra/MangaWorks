// The Swift Programming Language
// https://docs.swift.org/swift-book
// https://dev.jeremygale.com/swiftui-how-to-use-custom-fonts-and-images-in-a-swift-package-cl0k9bv52013h6bnvhw76alid

import Foundation
import SwiftUI
import LogManager
import GraceLanguage
import SoundManager

/// A utility for working with resources stored inside of this Swift Package.
open class MangaWorks {
    
    // MARK: - Enumerations
    /// Defines the source of a file.
    public enum Source {
        /// The file is from the App's Bundle.
        case appBundle
        
        /// The file is from the Swift Package's Bundle.
        case packageBundle
    }
    
    // MARK: Static Properties
    /// A notification to display in the simulated iPhone on the landscape view.
    public static var simulatediPhoneNotification:MangaDashboardNotification? = nil
    
    /// The default font color for Manga Actions.
    public static var actionFontColor:Color = .white
    
    /// The default background color for Manga Actions.
    public static var actionBackgroundColor:Color = Color(fromHex: "#8D52AF")!
    
    /// The default selected color for Manga Actions.
    public static var actionSelectedBackgroundColor:Color = Color(fromHex: "#EB244F")!
    
    /// The default border color for Manga Actions.
    public static var actionBorderColor:Color = Color(fromHex: "#533169")!
    
    /// The default selected border color for Manga Actions.
    public static var actionSelectedBorderColor:Color = .white
    
    /// The default foreground color for Manga Actions.
    public static var actionForegroundColor:Color = Color(fromHex: "#8D52AF")!
    
    /// The default highlight color for Manga Actions.
    public static var actionHighlightColor:Color = Color(fromHex: "#EB004F")!
    
    /// The default menu gradient colors.
    public static var menuGradient:[Color] = [Color(fromHex: "8D43C3")!, Color(fromHex: "8D43C3")!]
    
    /// The default menu selected gradient colors.
    public static var menuSelectedGradient:[Color] = [Color(fromHex: "#EB004F")!, Color(fromHex: "#EB004F")!]
    
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
    /// - Returns: Returns the `UIImage` if found, else returns `nil`.
    public static func image(name:String, withExtension:String = "png") -> UIImage? {
        let url = MangaWorks.urlTo(resource: name, withExtension: withExtension)
        return UIImage.scaledImage(bundleURL: url, scale: 1.0)
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
    
    /// Registers unctions with the Grace Language so they are available in MangaWorks Grace Scripts
    public static func registerGraceFunctions() {
        
        // Register all the required scripts
        SoundManager.registerGraceFunctions()
        MangaBook.registerGraceFunctions()
        MangaChapter.registerGraceFunctions()
    }
}
