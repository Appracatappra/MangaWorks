//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage

/// Adds an image to a Manga Page Panel.
@Observable open class MangaPagePanel {
    
    // MARK: - Enumerations
    /// Where the Image should display inside of the panel.
    public enum ImagePlacement: Int {
        /// The top leading postion.
        case topLeading = 0
        
        /// The top center position.
        case topCenter
        
        /// The top trailing postion.
        case topTrailing
        
        /// The middle leading postion.
        case middleLeading
        
        /// The middle center postion.
        case middleCenter
        
        /// The middle trailing postion.
        case middleTrailing
        
        /// The bottom leading postion.
        case bottomLeading
        
        /// The bottom center postion.
        case bottomCenter
        
        /// The bottom trailing postion.
        case bottomTrailing
    }
    
    // MARK: - Properties
    /// The title of the panel.
    public var title:String = ""
    
    /// The name  of the image to display in the panel.
    public var imageName:String = ""
    
    /// The image scale width.
    public var imageWidthScale:Float = 1.0
    
    /// The image scale height.
    public var imageHeightScale:Float = 1.0
    
    /// The image anchor point inside of the panel.
    public var imageAnchor:ImagePlacement = .middleCenter
    
    /// The panel horizontal offset.
    public var offsetHorizontal:CGFloat = 0.0
    
    /// The panel vertical offset.
    public var offsetVertical:CGFloat = 0.0
    
    /// The panel background color.
    public var backgroundColor:Color = .black
    
    /// The panel width scale.
    public var widthScale:CGFloat = 1.0
    
    /// The panel height scale.
    public var heightScale:CGFloat = 1.0
    
    /// A condition written in Grace Language that must evaluate to `true` for this panel to display.
    public var condition:String = ""
    
    // MARK: - Conditional Properties
    /// The calculated image scale width.
    private var imageWidthScaleDraw:CGFloat {
        return CGFloat(imageWidthScale * HardwareInformation.deviceRatioWidth)
    }
    
    /// The calculated image scale height.
    private var imageHeightScaleDraw:CGFloat {
        return CGFloat(imageHeightScale * HardwareInformation.deviceRatioHeight)
    }
    
    /// The calculated panel horizontal offset.
    private var offsetHorizontalDraw:CGFloat {
        return offsetHorizontal * CGFloat(HardwareInformation.deviceRatioWidth)
    }
    
    /// The calculated panel vertical offset.
    private var offsetVerticalDraw:CGFloat {
        return offsetVertical * CGFloat(HardwareInformation.deviceRatioHeight)
    }
    
    /// The filename of the image to display in the panel.
    private var filename:String {
        do {
            return try GraceRuntime.shared.expandMacros(in: imageName)
        } catch {
            return imageName
        }
    }
    
    // MARK: - Initializers
    public init(title:String = "", imageName:String = "", imageWidthScale:Float = 1.0, imageHeightScale:Float = 1.0, imageAnchor:ImagePlacement = .topLeading, offsetHorizontal:CGFloat = 0.0, offsetVertical:CGFloat = 0.0, backgroundColor:Color = .black, widthScale:Float = 1.0, heightScale:Float = 0.0, condition:String = "") {
        // Initialize
        self.title = title
        self.imageName = imageName
        self.imageWidthScale = imageWidthScale
        self.imageHeightScale = imageHeightScale
        self.imageAnchor = imageAnchor
        self.backgroundColor = backgroundColor
        self.widthScale = CGFloat(widthScale)
        self.heightScale = CGFloat(heightScale)
        self.offsetHorizontal = offsetHorizontal
        self.offsetVertical = offsetVertical
        self.condition = condition
    }
    
    // MARK: - Functions
    public func draw(mainContext:GraphicsContext, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let origin = CGPoint(x: x, y: y)
        var imageOrigin = CGPoint(x: x, y: y)
        let size = CGSize(width: width * widthScale, height: height * heightScale)
        var context = mainContext
        
        // Should we draw this panel?
        guard MangaWorks.evaluateCondition(condition) else {
            return
        }
        
        // Constrain Contents to context
        context.clip(to: Path(CGRect(origin: origin, size: size)))
        
        // Background Fill
        context.fill(Path(CGRect(origin: origin, size: size)), with: .color(backgroundColor))
        
        // Draw image
        if imageName != "" {
            if let sourceImage = UIImage.asset(named: filename, atWidthScale: imageWidthScaleDraw, atHeightScale: imageHeightScaleDraw) {
                switch imageAnchor {
                case .topLeading:
                    imageOrigin = CGPoint(x: x + offsetHorizontalDraw, y: y + offsetVerticalDraw)
                case .topCenter:
                    let offsetX = (sourceImage.size.width - size.width) / 2.0
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y + offsetVerticalDraw)
                case .topTrailing:
                    let offsetX = sourceImage.size.width - size.width
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y + offsetVerticalDraw)
                case .middleLeading:
                    let offsetY = (sourceImage.size.height - size.height) / 2.0
                    imageOrigin = CGPoint(x: x + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                case .middleCenter:
                    let offsetX = (sourceImage.size.width - size.width) / 2.0
                    let offsetY = (sourceImage.size.height - size.height) / 2.0
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                case .middleTrailing:
                    let offsetX = sourceImage.size.width - size.width
                    let offsetY = (sourceImage.size.height - size.height) / 2.0
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                case .bottomLeading:
                    let offsetY = sourceImage.size.height - size.height
                    imageOrigin = CGPoint(x: x + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                case .bottomCenter:
                    let offsetX = (sourceImage.size.width - size.width) / 2.0
                    let offsetY = sourceImage.size.height - size.height
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                case .bottomTrailing:
                    let offsetX = sourceImage.size.width - size.width
                    let offsetY = sourceImage.size.height - size.height
                    imageOrigin = CGPoint(x: x - offsetX + offsetHorizontalDraw, y: y - offsetY + offsetVerticalDraw)
                }
                let image = context.resolve(Image(uiImage: sourceImage))
                context.draw(image, at: imageOrigin, anchor: .topLeading)
            }
        }
        
        // Border
        context.stroke(Path(CGRect(origin: origin, size: size)), with: .color(.black), lineWidth: 4.0)
    }
}
