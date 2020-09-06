//
//  GameScene+PhysicsContact.swift
//  gloopdrop
//
//  Created by Michael Brünen on 06.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Check collision bodies
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // get the body which is the collectible
        let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible
            ? contact.bodyA.node
            : contact.bodyB.node

        // check if a [Collectible] collided with the [Player]
        if collision == PhysicsCategory.collectible | PhysicsCategory.player {
            if let sprite = body as? Collectible {
                sprite.collected()
            }
            print("Player hit collectible")
        }
        // or did the [Collectible] collide with the [Foreground]
        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            if let sprite = body as? Collectible {
                sprite.missed()
            }
            print("Collectible hit foreground")
        }
    }
}
