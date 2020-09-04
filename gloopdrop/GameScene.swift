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
    let player = Player()
    let playerMovementSpeed: CGFloat = 1.5

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
    }

    // MARK: - Touch input handling
    func touchDownAt(_ position: CGPoint) {
        // calculate necessary speed based on current and new position
        let distance = hypot(position.x - player.position.x, position.y - player.position.y)
        let speed = TimeInterval(distance / playerMovementSpeed) / 255
        let direction: PlayerDirection = position.x < player.position.x
            ? .left
            : .right
        player.moveTo(position, direction: direction, speed: speed)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDownAt(touch.location(in: self))
        }
    }
}
