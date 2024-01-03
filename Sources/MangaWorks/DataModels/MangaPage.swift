//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation

open class MangaPage: Identifiable {
    
    // MARK: - Properties
    public var id:String = ""
    
    var conversationA:MangaPageConversation? = nil
    
    var conversationB:MangaPageConversation? = nil
}
