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
}

// MARK: - SpriteKit extensions
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
}
