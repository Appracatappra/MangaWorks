//
//  File.swift
//  
//
//  Created by Kevin Mullins on 1/3/24.
//  From: https://forums.swift.org/t/how-to-load-skscene-from-a-swift-package/63450/14

import Foundation
import SpriteKit

/// A `NSKeyedUnarchiver` that can read the scenekit data from the Swift Package.
@objc(ModuleUnarchiver)
fileprivate final class ModuleUnarchiver: NSKeyedUnarchiver {
    
    // MARK: - Properties
    /// The bundle to read the data from.
    let bundle: Bundle

    // MARK: - Initializers
    /// Creates a new instance with data from a Swift Package.
    /// - Parameter data: The data containing the SceneKit Scene.
    init(fromPackageData data: Data) throws {
        self.bundle = Bundle.module

        try super.init(forReadingFrom: data)
    }
}

/// A `SKSpriteNode` that can get the texture from the Swift Package.
@objc(ModuleSpriteNode)
fileprivate final class ModuleSpriteNode: SKSpriteNode {
    
    // MARK: - Initializers
    /// Creates a new  instance.
    /// - Paramter coder: The `NSCoder` containing the data to construct the node from.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if
            let moduleUnarchiver = coder as? ModuleUnarchiver,
            let texture = value(forKey: "texture") as? SKTexture,
            let name = texture.value(forKey: "imgName") as? String,
            //let image = UIImage(named: name, in: moduleUnarchiver.bundle, with: nil)
            let image = MangaWorks.rawImage(name: name)
        {
            self.texture = .init(image: image)
        }
    }
}

/// Extends `SKScene` to load data from the Swift Package.
public extension SKScene {
    
    // MARK: - Static Functions
    /// Loads a `SceneKit Scene` from the Swift Package.
    /// - Parameter fileName: The filename of the scene to load.
    /// - Returns: Returns the loaded `SceneKit Scene`
    static func load<T>(packageScene fileName: String) -> T? where T: SKScene {
        
        guard
            let path = MangaWorks.pathTo(resource: fileName, ofType: "sks"),
            let data = FileManager.default.contents(atPath: path)
        else {
            return nil
        }
        
        do {
            let unarchiver = try ModuleUnarchiver(fromPackageData: data)
            unarchiver.requiresSecureCoding = false
            unarchiver.setClass(ModuleSpriteNode.self, forClassName: "SKSpriteNode")
            unarchiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")

            let scene = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
            unarchiver.finishDecoding()

            return scene as? T
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Gets the first `SKEmitterNode` found in a `SKScene` loaded from the Swift Package.
    /// - Parameter fileName: The name of the `SKScene` file to load.
    /// - Returns: Returns the first `SKEmitterNode` from the `SKScene` or a new `SKEmitterNode` if not found.
    static func getfirstEmitter(from fileName: String) -> SKEmitterNode {
        
        if let scene = SKScene.load(packageScene: "Rain.sks") {
            if let emitter = scene.getFirstEmitter() {
                return emitter
            } else {
                return SKEmitterNode()
            }
        } else {
            return SKEmitterNode()
        }
    }
    
    /// Returns the first emitter node from the SKScene.
    /// - Returns: Returns the first `SKEmitterNode` or `nil` if not found.
    func getFirstEmitter() -> SKEmitterNode? {
        
        for child in children {
            if let emitter = child as? SKEmitterNode {
                return emitter
            }
        }
        
        return nil
    }
}
