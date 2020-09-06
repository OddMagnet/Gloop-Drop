//
//  Player.swift
//  gloopdrop
//
//  Created by Michael Brünen on 04.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import SpriteKit

// enum to switch between animations
enum PlayerAnimationType: String {
    case walk
}

// enum to switch player direction
//enum PlayerDirection {
//    case left
//    case right
//}

class Player: SKSpriteNode {
    // MARK: - Properties
    private var walkTextures: [SKTexture]?
    private var walkingSpeed = 0.15
    private var height: CGFloat { texture?.size().height ?? 0 }
    private var width: CGFloat { texture?.size().width ?? 0 }

    // MARK: - Init
    init() {
        // set default texture
        let texture = SKTexture(imageNamed: "blob-walk_0")

        // call to super.init
        super.init(texture: texture, color: .clear, size: texture.size())

        // setup animation textures
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)

        // set up other properties after init
        self.name = "player"
        self.setScale(1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0) // center bottom
        self.zPosition = Layer.player.rawValue

        // Add physics body
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: self.height / 2))
        self.physicsBody?.affectedByGravity = false

        // set up physics categories for contacts
        self.physicsBody?.categoryBitMask = PhysicsCategory.player          // set the category the player belongs to
        self.physicsBody?.contactTestBitMask = PhysicsCategory.collectible  // only care about contact with collectibles
        self.physicsBody?.collisionBitMask = PhysicsCategory.none           // ignore collisions completely
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    /// Sets up constraints for the player sprite
    /// - Parameter floor: The floor the player sprite is limited to move to on the Y-Axis
    func setUpConstraints(floor: CGFloat) {
        let range = SKRange(constantValue: floor)
        let lockToPlattform = SKConstraint.positionY(range)

        constraints = [lockToPlattform]
    }

    /// Starts the walking animation
    func walk() {
        // check for textures
        guard let walkTextures = walkTextures else { preconditionFailure("Could not find textures for walking animation") }

        // run the animation forever
        startAnimation(textures: walkTextures,
                       speed: walkingSpeed,
                       animationKeyName: PlayerAnimationType.walk.rawValue,
                       resize: true,
                       restore: true)
    }

    /// Moves the player sprite
    /// - Parameters:
    ///   - position: The position to move the sprite to
    ///   - direction: The direction the sprite is facing
    ///   - speed: The speed at which the sprite moves to the new position
//    func moveTo(_ position: CGPoint, direction: PlayerDirection, speed: TimeInterval) {
//        switch direction {
//            case .left:
//                xScale = -abs(xScale)
//            case .right:
//                xScale = abs(xScale)
//        }
//        let moveAction = SKAction.move(to: position, duration: speed)
//        run(moveAction)
//    }
}
