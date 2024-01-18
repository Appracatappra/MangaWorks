//
//  BattleDiceResults.swift
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

/// Displays the results of a dice roll without the animation.
public struct MangaDiceResultsView: View {
    
    // MARK: - Initializer
    /// Creates a new instance.
    /// - Parameters:
    ///   - numberOfDice: The number of dice to roll between 1 and 4.
    ///   - diceValues: The values for the individual dice.
    ///   - fontColor: The color to draw the grand total in.
    public init(numberOfDice: Int = 4, diceValues: [Int] = [0,0,0,0], fontColor: Color = MangaWorks.controlForegroundColor) {
        self.numberOfDice = numberOfDice
        self.diceValues = diceValues
        self.fontColor = fontColor
    }
    
    // MARK: - Properties
    /// The number of dice to roll between 1 and 4.
    public var numberOfDice:Int = 4
    
    /// The values for the individual dice.
    public var diceValues:[Int] = []
    
    /// The color to draw the grand total in.
    public var fontColor:Color = MangaWorks.controlForegroundColor
    
    // MARK: - Computed Properties
    /// Gets the font size based on the deivce.
    private var titleSize:CGFloat {
        if HardwareInformation.isPhone {
            return 18
        } else {
            return 64
        }
    }
    
    /// Returns the grand total of all dice rolled.
    private var total:Int {
        var sum:Int = 0
        
        for diceValue in diceValues {
            sum += diceValue
        }
        
        return sum
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        HStack {
            if let image = MangaWorks.image(name: "Dice0\(diceValues[0])A") {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            }
            
            if numberOfDice >= 2 {
                if let image = MangaWorks.image(name: "Dice0\(diceValues[1])A") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            
            if numberOfDice >= 3 {
                if let image = MangaWorks.image(name: "Dice0\(diceValues[2])A") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            
            if numberOfDice >= 4 {
                if let image = MangaWorks.image(name: "Dice0\(diceValues[3])A") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            
            Text(" = \(total)")
                .font(.system(size: titleSize, weight: .bold, design: .default))
                .foregroundColor(fontColor)
        }
    }
}

#Preview {
    MangaDiceResultsView()
}
