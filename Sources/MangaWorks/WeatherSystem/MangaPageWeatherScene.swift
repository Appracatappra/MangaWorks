//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//
//  Original Source: https://betterprogramming.pub/rain-lightning-animation-using-spritekit-in-swiftui-part-1-%EF%B8%8F-e2cf489e5d25
//  and: https://medium.com/better-programming/rain-lightning-animation-using-spritekit-in-swiftui-part-ii-837ee74f6bd3
//

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SwiftUIPanoramaViewer
import SpriteKit

/// SpriteKit Scene to handle weather animations to a location in the game.
open class MangaPageWeatherScene: SKScene {

    // MARK: - Static Properties
    /// A common, shared instance of the weather scene.
    public static var shared = MangaPageWeatherScene()
    
    public static var fileSource:MangaWorks.Source = .packageBundle
    
    public static func LoadEmitter(filename:String, particleName:String) -> SKEmitterNode {
        
        // Source?
        if MangaPageWeatherScene.fileSource == .appBundle {
            if let emitter = SKEmitterNode(fileNamed: "\(filename).sks") {
                return emitter
            }
        } else {
            // Generate a path to the file
            if let sksPath = MangaWorks.pathTo(resource: filename, ofType: "sks") {
                if let emitter = SKEmitterNode(fileNamed: sksPath) {
                    if let image = MangaWorks.rawImage(name: particleName, withExtension: "png") {
                        emitter.particleTexture = SKTexture(image: image)
                    }
                    
                    return emitter
                }
            }
        }
        
        // Not able to load
        return SKEmitterNode()
    }

    // MARK: - Properties
    /// The common shared rain effect emitter.
    public var rainEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Rain", particleName: "spark")
    
    /// The common shared fog effect emitter.
    public let fogEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Fog", particleName: "fog")
    
    /// The common shared leaf effect emitter.
    public let leafEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Leaves", particleName: "RedMapleLeaf")
    
    /// The common shared blown paper effect emitter.
    public let paperEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Paper", particleName: "TornPaper")
    
    /// The common shared bokeh effect emitter.
    public let bokehEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Bokeh", particleName: "boken")
    
    /// The common shared glitch effect emitter.
    public let glitchEmitter:SKEmitterNode = MangaPageWeatherScene.LoadEmitter(filename: "Glitch01", particleName: "Glitch01")
    
    /// If `true` then the rain effect will be shown, else it will not.
    public var hasRain:Bool {
        get {
            return rainEmitter.particleBirthRate == 600
        }
        set {
            if newValue {
                rainEmitter.particleBirthRate = 600
            } else {
                rainEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then the bokeh effect will be shown, else it will not.
    public var hasBokeh:Bool {
        get {
            return bokehEmitter.particleBirthRate == 10
        }
        set {
            if newValue {
                bokehEmitter.particleBirthRate = 10
            } else {
                bokehEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then the glitch effect will be shown, else it will not.
    public var hasGlitch:Bool {
        get {
            return glitchEmitter.particleBirthRate == 15
        }
        set {
            if newValue {
                glitchEmitter.particleBirthRate = 15
            } else {
                glitchEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then the fog effect will be shown, else it will not.
    public var hasFog:Bool {
        get {
            return fogEmitter.particleBirthRate == 20.131
        }
        set {
            if newValue {
                fogEmitter.particleBirthRate = 20.131
            } else {
                fogEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then the falling leaf effect will be shown, else it will not.
    public var hasFallingLeaves:Bool {
        get {
            return leafEmitter.particleBirthRate == 5
        }
        set {
            if newValue {
                leafEmitter.particleBirthRate = 5
            } else {
                leafEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then the blown paper effect will be shown, else it will not.
    public var hasBlownPaper:Bool {
        get {
            return paperEmitter.particleBirthRate == 5
        }
        set {
            if newValue {
                paperEmitter.particleBirthRate = 5
            } else {
                paperEmitter.particleBirthRate = 0
            }
        }
    }
    
    /// If `true` then it is lightning at the current location, else it is not.
    public var hasLightning:Bool = false
    
    // MARK: - Private Variables
    /// If `true` the rain emitter has been configured and added to the scene
    private var rainConfigured:Bool = false
    
    /// If `true` the fog emitter has been configured and added to the scene
    private var fogConfigured:Bool = false
    
    /// If `true` the leaf emitter has been configured and added to the scene
    private var leafConfigured:Bool = false
    
    /// If `true` the blown paper emitter has been configured and added to the scene
    private var paperConfigured:Bool = false
    
    /// If `true` the bokeh emitter has been configured and added to the scene
    private var bokehConfigured:Bool = false
    
    /// If `true` the glitch emitter has been configured and added to the scene
    private var glitchConfigured:Bool = false
    
    // MARK: - Functions
    /// This function will be called when the Scene is being removed from a view.
    /// - Parameter view: The view that the scene is being removed from.
    public override func willMove(from view: SKView) {
        if rainConfigured {
            rainEmitter.removeFromParent()
            rainConfigured = false
        }
        
        if bokehConfigured {
            bokehEmitter.removeFromParent()
            bokehConfigured = false
        }
        
        if glitchConfigured {
            glitchEmitter.removeFromParent()
            glitchConfigured = false
        }
        
        if fogConfigured {
            fogEmitter.removeFromParent()
            fogConfigured = false
        }
        
        if leafConfigured {
            leafEmitter.removeFromParent()
            leafConfigured = false
        }
        
        if paperConfigured {
            paperEmitter.removeFromParent()
            paperConfigured = false
        }
    }
    
    /// This function is called when a scene is about to be added to a view.
    /// - Parameter view: The view the scene is being added to.
    public override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        if !rainConfigured {
            self.addChild(rainEmitter)
            rainEmitter.position.y = self.frame.maxY
            rainEmitter.particlePositionRange.dx = self.frame.width * 2.5
            rainConfigured = true
        }
        
        if !bokehConfigured {
            self.addChild(bokehEmitter)
            bokehEmitter.position.y = self.frame.maxY / 2.0
            bokehEmitter.particlePositionRange.dx = self.frame.width * 2.5
            bokehConfigured = true
        }
        
        if !fogConfigured {
            self.addChild(fogEmitter)
            fogEmitter.position.y = 0
            fogEmitter.particlePositionRange.dx = self.frame.width * 2.5
            fogConfigured = true
        }
        
        if !leafConfigured {
            self.addChild(leafEmitter)
            leafEmitter.position.y = self.frame.maxY
            leafEmitter.particlePositionRange.dx = self.frame.width * 2.5
            leafConfigured = true
        }
        
        if !paperConfigured {
            self.addChild(paperEmitter)
            paperEmitter.position.y = self.frame.maxY
            paperEmitter.particlePositionRange.dx = self.frame.width * 2.5
            paperConfigured = true
        }
        
        if !glitchConfigured {
            self.addChild(glitchEmitter)
            glitchEmitter.position.y = self.frame.maxY / 2.0
            glitchEmitter.particlePositionRange.dx = self.frame.width * 2.5
            glitchConfigured = true
        }
        
    }
    
    /// This function is called even time the sceen needs to be updated.
    /// - Parameter currentTime: The current time that the simulation has been running.
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if hasLightning {
            let trigger = Int.random(in: 1...3000)
            
            if trigger < 10 {
                self.lightningFlasher(flashCount: 1)
            }
        }
    }
    
    /// Function to flash the screen to simulate lightening in the distance.
    /// - Parameter flashCount: The number of times that the flash repeats.
    public func lightningFlasher(flashCount: Int = 0) {
        let whiteFlash: SKAction = SKAction.run { () -> Void in
            self.backgroundColor = UIColor(Color(fromHex: "#70707001")!)
        }
            
        let darkFlash: SKAction = SKAction.run { () -> Void in
            self.backgroundColor = .clear
        }

        let waitAction: SKAction = SKAction.wait(forDuration: 0.20) // 0.05
            
        run(SKAction.repeat(SKAction.sequence([whiteFlash,
                        waitAction,
                        darkFlash,
                        waitAction]), count: flashCount))
    }
    
}
