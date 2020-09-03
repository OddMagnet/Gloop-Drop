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

    override func didMove(to view: SKView) {
        // set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.anchorPoint = .zero
        background.position = .zero
        addChild(background)

        // set up foregroung
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.anchorPoint = .zero
        foreground.position = .zero
        addChild(foreground)
    }
    
}
