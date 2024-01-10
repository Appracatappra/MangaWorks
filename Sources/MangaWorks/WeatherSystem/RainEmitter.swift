//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/10/24.
//  https://akdebuging.com/posts/how-to-use-SKEmitterNode-programatically/

import Foundation
import SwiftUI
import Observation
import SwiftletUtilities
import GraceLanguage
import SwiftUIPanoramaViewer
import SpriteKit

// KKM - This doesn't work for some reason, even though I'm fully recreating the emitter in code..
open class RainEmitter {
    
    public static var emitter:SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Add texture image
        if let image = MangaWorks.rawImage(name: "spark", withExtension: "png") {
            emitter.particleTexture = SKTexture(image: image)
        }
        
        // Construct Emitter
        emitter.particleBirthRate = 600
        emitter.numParticlesToEmit = 0
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 0
        emitter.particlePosition = CGPoint(x: 242.3, y: 5)
        emitter.particleZPosition = 0
        emitter.emissionAngle = 360 * .pi / 265
        emitter.emissionAngleRange = 360 * .pi / 1.719
        emitter.particleSpeed = 340
        emitter.particleSpeedRange = 150
        emitter.xAcceleration = 0
        emitter.yAcceleration = -150
        emitter.particleAlpha = 1
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = 0
        emitter.particleScale = 0.1
        emitter.particleScaleRange = 0.05
        emitter.particleScaleSpeed = 0
        emitter.particleRotation = 0
        emitter.particleRotationRange = 0
        emitter.particleRotationSpeed = 0
        emitter.particleColorBlendFactor = 1
        emitter.particleColorBlendFactorRange = 0
        emitter.particleColorBlendFactorSpeed = 0
        emitter.particleBlendMode = .alpha
        
        return emitter
    }
}
