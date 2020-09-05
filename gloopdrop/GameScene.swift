//
//  GameScene.swift
//  gloopdrop
//
//  Created by Michael Brünen on 03.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: - Properties
    let player = Player()
    let playerMovementSpeed: CGFloat = 1.5
    var movingPlayer = false
    var lastPosition: CGPoint?
    var level: Int = 1
    var minDropSpeed: CGFloat = 0.12    // fastest drop speed
    var maxDropSpeed: CGFloat = 1.0     // slowest drop speed

    // MARK: - Computed properties
    var numberOfDrops: Int {
        switch level {
            case 1...5:
                return level * 10
            case 6:
                return 75
            case 7:
                return 100
            case 8:
                return 125
            default:
                return 150
        }
    }
    var dropSpeed: CGFloat {
        var speed = 1.1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if speed < minDropSpeed { speed = minDropSpeed }
        else if speed > maxDropSpeed { speed = maxDropSpeed }
        return speed
    }

    // MARK: - Init
    override func didMove(to view: SKView) {
        // set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.anchorPoint = .zero
        background.zPosition = Layer.background.rawValue
        background.position = .zero
        addChild(background)

        // set up foreground
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.anchorPoint = .zero
        foreground.zPosition = Layer.foreground.rawValue
        foreground.position = .zero
        addChild(foreground)

        // set up player
        // initially place the player sprite centered horizontally and on top of the foreground node
        player.position = CGPoint(x: size.width / 2, y: foreground.frame.maxY)
        player.setUpConstraints(floor: foreground.frame.maxY)
        addChild(player)
        // start up the player animation
        player.walk()

        // set up game
        spawnMultipleGloops()
    }

    // MARK: - Game functions
    func spawnMultipleGloops() {
        // set up repeating action
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in
            self.spawnGloop()
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)

        // run action
        run(repeatAction)
    }

    func spawnGloop() {
        let collectible = Collectible(collectibleType: .gloop)

        // set random position
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)

        // set up the drop
        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: 1.0, floorLevel: player.frame.minY)
    }

    // MARK: - Touch input handling
    func touchDownAt(_ position: CGPoint) {
//        // calculate necessary speed based on current and new position
//        let distance = hypot(position.x - player.position.x, position.y - player.position.y)
//        let speed = TimeInterval(distance / playerMovementSpeed) / 255
//        let direction: PlayerDirection = position.x < player.position.x
//            ? .left
//            : .right
//        player.moveTo(position, direction: direction, speed: speed)
        let touchedNode = atPoint(position)
        if touchedNode.name == "player" {
            movingPlayer = true
        }
    }

    func touchMovedTo(_ position: CGPoint) {
        if movingPlayer {
            // clamp position
            let newPosition = CGPoint(x: position.x, y: player.position.y)
            player.position = newPosition

            // check last position, if empty set it
            let recordedPosition = lastPosition ?? player.position
            if recordedPosition.x > newPosition.x { player.xScale = -abs(xScale) }
            else { player.xScale = abs(xScale) }

            // save the last known position
            lastPosition = newPosition
        }
    }

    func touchUpAt(_ position: CGPoint) {
        movingPlayer = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDownAt(touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchMovedTo(touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchUpAt(touch.location(in: self))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchUpAt(touch.location(in: self))
        }
    }
}
