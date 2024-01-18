//
//  DiceRoll.swift
//  Escape from Mystic Manor
//
//  Created by Kevin Mullins on 11/16/21.
//  Based on: https://stackoverflow.com/questions/56722695/how-to-animate-a-sequence-of-images-using-swiftui
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import GraceLanguage
import SpeechManager
import SoundManager
import LogManager

/// Handles a virtual dice roll and reports the result back to the caller via the `rolled` event handler.
public struct MangaDiceRoll: View {
    // MARK: Event Handlers
    /// Handles the dice roll completing.
    public typealias RollCompleted = (Int) -> Void
    
    // MARK: - Initializers
    public init(size:Float = 150, completed:RollCompleted? = nil) {
        self.rolled = completed
        self.size = size
    }
    
    // MARK: - Properties
    /// The size to draw the dice at.
    public var size:Float = 150
    
    /// The handler that is call when the roll is completed.
    public var rolled:RollCompleted? = nil

    // MARK: - States
    /// The dice side that is currently being shown.
    @MutableValue private var side = 1
    
    /// A timer that handles the dice roll visual display and sound effects.
    @MutableValue var timer:SwiftUITimer? = nil
    
    /// The number of times the dice has rolled.
    @State private var count = 0
    
    /// An index to the dice image being displayed.
    @State private var index = 1

    // MARK: - Computed Properties
    private var widthHeight:CGFloat {
        return CGFloat(size)
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        if let image = MangaWorks.image(name: randomDiceSide(side: index)) {
            Image(uiImage: image)
            .resizable()
            .frame(width: widthHeight, height: widthHeight, alignment: .center)
            .onAppear {
            self.timer = SwiftUITimer(interval: 0.1, onTick: {
                if self.count >= 5 {
                    self.timer?.stop()
                    if let rolled = self.rolled {
                        rolled(self.side)
                    }
                } else {
                    self.count += 1
                    self.side = Int.random(in: 1...6)
                    self.index = self.side
                }
            })
            self.timer?.start()
            SoundManager.shared.playSoundEffect(path: MangaWorks.pathTo(resource: "Magnesus_DiceRoll", ofType: "mp3"), channel: .channel02)
        }
    }
    }
    
    // MARK: - Functions
    /// Draws the side view at random.
    /// - Parameter side: The side displayed.
    /// - Returns: Returns a random version of the dice side.
    private func randomDiceSide(side:Int) -> String {
        var image = ""
        let variant = Int.random(in: 1...4)
        
        switch variant {
        case 1:
            image = "Dice0\(side)A"
        case 2:
            image = "Dice0\(side)B"
        case 3:
            image = "Dice0\(side)C"
        case 4:
            image = "Dice0\(side)D"
        default:
            break
        }
        
        return image
    }
    
}

#Preview {
    MangaDiceRoll()
}
