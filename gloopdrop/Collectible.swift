//
//  Collectible.swift
//  gloopdrop
//
//  Created by Michael Brünen on 05.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import SpriteKit

// TODO: Add more collectibles, like power ups, extra lifes, etc
enum CollectibleType: String {
    case none
    case gloop
}

class Collectible: SKSpriteNode {
    // MARK: - Properties
    private var collectibleType: CollectibleType = .none
    private var height: CGFloat { texture?.size().height ?? 0 }
    private var width: CGFloat { texture?.size().width ?? 0 }

    // MARK: - Init
    init(collectibleType: CollectibleType) {
        var texture: SKTexture!
        self.collectibleType = collectibleType

        // set the texture
        switch self.collectibleType {
            case .gloop:
                texture = SKTexture(imageNamed: "gloop")
            case .none:
                break
        }

        // call super.init
        super.init(texture: texture, color: .clear, size: texture.size())

        // set up collectible
        self.name = "co_\(collectibleType)"
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.collectible.rawValue

        // Add physics body
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: -self.height / 2))
        self.physicsBody?.affectedByGravity = false

        // set up physics categories for contact
        self.physicsBody?.categoryBitMask = PhysicsCategory.collectible                             // set the category the collectible belongs to
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.foreground  // only care about contact with player or foreground
        self.physicsBody?.collisionBitMask = PhysicsCategory.none                                   // ignore collisions completely
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not been implemented yet")
    }

    // MARK: - Functions
    /// Starts the drop animation of the collectible
    /// - Parameters:
    ///   - dropSpeed: The speed at which the collectible drops
    ///   - floorLevel: The point on the Y-Axis where the collectible hits the floor
    func drop(dropSpeed: TimeInterval, floorLevel: CGFloat) {
        let pos = CGPoint(x: position.x, y: floorLevel + (self.height))
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)

        let scale = SKAction.group([scaleX, scaleY])
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let move = SKAction.move(to: pos, duration: dropSpeed)

        let actionSequence = SKAction.sequence([appear, scale, move])

        // shrink first, then run action sequence
        self.scale(to: CGSize(width: 0.25, height: 1.0))
        self.run(actionSequence, withKey: "drop")
    }

    /// Removes a drop from the scene
    func remove() {
        let removeFromParent = SKAction.removeFromParent()
        self.run(removeFromParent)
    }

    func collected() {
        self.remove()
    }

    func missed() {
        self.remove()
    }
}
