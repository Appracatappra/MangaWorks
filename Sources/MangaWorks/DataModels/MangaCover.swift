//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/5/24.
//

import Foundation
import SwiftletUtilities
import LogManager
import SpeechManager
import GraceLanguage
import SwiftUIPanoramaViewer
import SwiftUI
import SoundManager
import SimpleSerializer
import Observation

@Observable open class MangaCover {
    
    // MARK: - Properties
    public var title:String = ""
    
    public var coverBackgroundImage:String = ""
    
    public var coverBackgroundBarcodeImage:String = ""
    
    public var coverForegroundImage:String = ""
    
    public var eddition:String = "Premier Eddition"
    
    public var country:String = "USA"
    
    public var subtitle:String = "Manga Magazine #1"
    
    public var price:String = "$2.99 US"
}
