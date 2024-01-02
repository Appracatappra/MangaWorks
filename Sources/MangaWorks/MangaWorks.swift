// The Swift Programming Language
// https://docs.swift.org/swift-book
// https://dev.jeremygale.com/swiftui-how-to-use-custom-fonts-and-images-in-a-swift-package-cl0k9bv52013h6bnvhw76alid

import Foundation
import SwiftUI
import LogManager

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
    public static var simulatediPhoneNotification:MangaDashboardNotification? = nil
    
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
}
