//
//  GameScene+PhysicsContact.swift
//  gloopdrop
//
//  Created by Michael Brünen on 06.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import SpriteKit

/// This part of the GameScene class contains the handling of physics, e.g. the player catching or missing the drops
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
                dropsCollected += 1
                score += level
                checkForRemainingDrops()

                // add chomp text at the players position
                let chomp = SKLabelNode(fontNamed: "Nosifer")
                chomp.name = "chomp"
                chomp.fontSize = 22.0
                chomp.text = "gloop"
                chomp.horizontalAlignmentMode = .center
                chomp.verticalAlignmentMode = .bottom
                chomp.position = CGPoint(x: player.position.x,
                                         y: player.frame.maxY + 25)
                chomp.zRotation = CGFloat.random(in: -0.15...0.15)
                addChild(chomp)

                // add actions to fade in, rise up and fade out
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.45)
                let moveUp = SKAction.moveBy(x: 0, y: 45, duration: 0.45)
                let groupAction = SKAction.group([fadeOut, moveUp])
                let removeFromParent = SKAction.removeFromParent()
                let chompAction = SKAction.sequence([fadeIn, groupAction, removeFromParent])
                chomp.run(chompAction)
            }
//            print("Player hit collectible")
        }
        // or did the [Collectible] collide with the [Foreground]
        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            if let sprite = body as? Collectible {
                sprite.missed()
                gameOver()
            }
//            print("Collectible hit foreground")
        }
    }
}
