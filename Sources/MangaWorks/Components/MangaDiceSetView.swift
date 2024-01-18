//
//  BattleDiceView.swift
//  Escape from Mystic Manor
//
//  Created by Kevin Mullins on 11/30/21.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SoundManager
import LogManager

/// A UI that handles the rolling a set of 1 to 4 dice and returning the results to the caller.
public struct MangaDiceSetView: View {
    // MARK: - Event Handlers
    /// Handles the roll being completed. Returns both the individual dice rolls and the grand total of all dice.
    public typealias RollCompleted = ([Int], Int) -> Void
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - numberOfDice: The number of dice being rolled from 1 to 4.
    ///   - fontColor: The color to draw the grand total in.
    ///   - completed: Handles the roll being completed and returns the results.
    public init(numberOfDice: Int = 4, fontColor: Color = MangaWorks.controlForegroundColor, completed: RollCompleted! = nil) {
        self.numberOfDice = numberOfDice
        self.fontColor = fontColor
        self.completed = completed
    }
    
    // MARK: - Properties
    /// The number of dice being rolled from 1 to 4.
    public var numberOfDice:Int = 4
    
    /// The color to draw the grand total in.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    /// Handles the roll being completed and returns the results.
    public var completed:RollCompleted! = nil
    
    // MARK: - States
    /// Holds the current dice rolls.
    @MutableValue var diceValues:[Int] = [0, 0, 0, 0]
    
    /// Holds the total for all dice rolled.
    @State private var total:Int = 0
    
    /// If `true`, show the second dice.
    @State private var showDice2:Bool = false
    
    /// If `true`, show the third dice.
    @State private var showDice3:Bool = false
    
    /// If `true`, show the fourth dice.
    @State private var showDice4:Bool = false
    
    // MARK: - Computed Properties
    /// Gets the font size based on the device.
    private var titleSize:CGFloat {
        if HardwareInformation.isPhone {
            return 18
        } else {
            return 64
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        HStack {
            MangaDiceRoll(size: 100, completed: { value in
                total += value
                diceValues[0] = value
                sendResults(forDice: 1)
                showDice2 = true
            })
            
            if numberOfDice >= 2 && showDice2 {
                MangaDiceRoll(size: 100, completed: { value in
                    total += value
                    diceValues[1] = value
                    sendResults(forDice: 2)
                    showDice3 = true
                })
            }
        
            if numberOfDice >= 3 && showDice3 {
                MangaDiceRoll(size: 100, completed: { value in
                    total += value
                    diceValues[2] = value
                    sendResults(forDice: 3)
                    showDice4 = true
                })
            }
            
            if numberOfDice >= 4 && showDice4 {
                MangaDiceRoll(size: 100, completed: { value in
                    total += value
                    diceValues[3] = value
                    sendResults(forDice: 4)
                })
            }
            
            Text(" = \(total)")
                .font(.system(size: titleSize, weight: .bold, design: .default))
                .foregroundColor(fontColor)
        }
        
    }
    
    // MARK: - Functions
    /// Sends the results of the last dice roll to the user.
    /// - Parameter forDice: The dice that is currently being rolled.
    private func sendResults(forDice:Int) {
        
        guard let completed = completed else {
            return
        }
        
        if forDice == numberOfDice {
            completed(diceValues, total)
        }
    }
}

#Preview {
    MangaDiceSetView()
}
