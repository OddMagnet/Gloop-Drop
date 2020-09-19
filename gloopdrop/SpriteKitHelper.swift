//
//  SpriteKitHelper.swift
//  gloopdrop
//
//  Created by Michael Brünen on 04.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - SpriteKit Helpers
// set up shared z-positions
enum Layer: CGFloat {
    case background
    case foreground
    case player
    case collectible
    case ui
}

// set up physics categories
enum PhysicsCategory {
    static let none:        UInt32 = 0
    static let player:      UInt32 = 0b1    // 1
    static let collectible: UInt32 = 0b10   // 2
    static let foreground:  UInt32 = 0b100  // 4
}

// MARK: - SKNode extension
extension SKNode {
    /// Sets up a endless scrolling view for a node
    /// - Parameters:
    ///   - name: The name of the image used for the scrolling view
    ///   - layer: The layer at which the scroll should be
    ///   - emitterNamed: (Optional) The emitter used for particle effects
    ///   - blocks: The amount of blocks used for the scrolling view
    ///   - speed: The speed of the scrolling
    func setUpScrollingView(imageNamed name: String,
                            layer: Layer,
                            emitterNamed: String?,
                            blocks: Int,
                            speed: TimeInterval) {
        // create sprite nodes and set their position based on their # and width
        for i in 0..<blocks {
            let spriteNode = SKSpriteNode(imageNamed: name)
            spriteNode.anchorPoint = .zero
            spriteNode.position = CGPoint(x: CGFloat(i) * spriteNode.size.width,
                                          y: 0)
            spriteNode.zPosition = layer.rawValue
            spriteNode.name = name

            // set up optional particles
            if let emitterNamed = emitterNamed,
                let particles = SKEmitterNode(fileNamed: emitterNamed) {
                particles.name = "particles"
                spriteNode.addChild(particles)
            }

            // use custom extension to scroll
            spriteNode.endlessScroll(speed: speed)
            addChild(spriteNode)
        }
    }
}

// MARK: - SpriteKitNode extension
extension SKSpriteNode {
    /// Helper function to load an array of textures
    /// - Parameters:
    ///   - atlas: The name of the atlas to load the texures from
    ///   - prefix: The prefix of the textures
    ///   - startIndex: The  index of the first texture to be included in the returned array, e.g. prefix_startIndex
    ///   - stopIndex: The  index of the last texture to be included in the returned array, e.g. prefix_stopIndex
    /// - Returns: An array of textures
    func loadTextures(atlas: String, prefix: String, startsAt startIndex: Int, stopsAt stopIndex: Int) -> [SKTexture] {
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)

        for index in startIndex...stopIndex {
            let textureName = "\(prefix)\(index)"
            let texture = textureAtlas.textureNamed(textureName)
            textureArray.append(texture)
        }

        return textureArray
    }

    /// Creates an animation loop based on supplied parameters
    /// - Parameters:
    ///   - textures: An array of animation used for the textures
    ///   - speed: The speed of the animation
    ///   - animationKeyName: The name assigned to the animation key
    ///   - count: Optional. The amount of repeats for the animation, defaults to forever when omitted
    ///   - resize: If the sprite's size should match the images size
    ///   - restore: If the original texture is restored when the animation is finished
    func startAnimation(textures: [SKTexture], speed: Double, animationKeyName name: String, count: Int = 0, resize: Bool, restore: Bool) {
        // only run it, if the animation key doesn't exist already
        if (action(forKey: name) == nil) {
            let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)

            if count == 1 {
                run(animation, withKey: name)
            } else {
                // run animation \(count) amount, default being 0 for forever, until stopped externally
                let repeatAction = count == 0
                    ? SKAction.repeatForever(animation)
                    : SKAction.repeat(animation, count: count)
                run(repeatAction, withKey: name)
            }
        }
    }

    /// Creates an endless scrolling action and starts it
    /// - Parameter speed: The speed of the scrolling
    func endlessScroll(speed: TimeInterval) {
        // set up actions for moving and resetting nodes
        let moveAction = SKAction.moveBy(x: -self.size.width, y: 0, duration: speed)
        let resetAction = SKAction.moveBy(x: self.size.width, y: 0, duration: 0.0)

        // set up a sequence to repeat those actions
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)

        // finall run it
        run(repeatAction)
    }
}

// MARK: - SKScene extensions
extension SKScene {
    /// Returns the value of the top point of the view in the scene
    func viewTop() -> CGFloat {
        return convertPoint(fromView: CGPoint(x: 0.0, y: 0)).y
    }

    /// Returns the value of the bottom point of the view in the scene
    func viewBottom() -> CGFloat {
        guard let view = view else { return 0.0 }
        return convertPoint(fromView: CGPoint(x: 0.0, y: view.bounds.size.height)).y
    }
}
