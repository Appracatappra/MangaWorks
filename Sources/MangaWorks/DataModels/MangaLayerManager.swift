//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//

import Foundation

// Defines an operator used to provide syntatic sugar when converting a `ElementVisibility` to an `Int`.
prefix operator ⊛

open class MangaLayerManager {
    
    // MARK: - Enumerations
    /// Defines the condition that must be met to display an element in the layout system.
    public enum ElementVisibility {
        case displayNothing
        case displayAlways
        case displaySearch
        case displaySearchAlt
        case displayUse
        case displayUseAlt
        case displayTalk
        case displayTalkAlt
        case displayExamine
        case displayExamineAlt
        case displayNav
        case displayNavAlt
        case displayAttack
        case displayAttackAlt
        case displayHack
        case displayHackAlt
        case displayCall
        case displayCallAlt
        case displayNextLocation
        case displayConversationA
        case displayConversationB
        case displayConversationResultA
        case displayConversationResultB
        
        /// Syntatic sugar to convert a `ElementVisibility` to an `Int`.
        /// - Parameter lhs: The `ElementVisibility`  to convert.
        /// - Returns: The value converted to an `Int`.
        public static prefix func ⊛(lhs:ElementVisibility) -> Int {
            return lhs.value
        }
        
        /// Returns the `ElementVisibility` as an `Int`.
        /// - remark: This was written this way because the compiler was getting confused if I attached the `Int` value to each case andtried to pass it as a parameter to a func.
        public var value:Int {
            switch self {
            case .displayNothing:
                return -1
            case .displayAlways:
                return -2
            case .displaySearch:
                return -3
            case .displaySearchAlt:
                return -4
            case .displayUse:
                return -5
            case .displayUseAlt:
                return -6
            case .displayTalk:
                return -7
            case .displayTalkAlt:
                return -8
            case .displayExamine:
                return -9
            case .displayExamineAlt:
                return -10
            case .displayNav:
                return -11
            case .displayNavAlt:
                return -12
            case .displayAttack:
                return -13
            case .displayAttackAlt:
                return -14
            case .displayHack:
                return -15
            case .displayHackAlt:
                return -16
            case .displayCall:
                return -17
            case .displayCallAlt:
                return -18
            case .displayNextLocation:
                return -19
            case .displayConversationA:
                return -20
            case .displayConversationB:
                return -21
            case .displayConversationResultA:
                return -22
            case .displayConversationResultB:
                return -23
            }
        }
    }
}
