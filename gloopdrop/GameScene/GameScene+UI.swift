//
//  GameScene+UI.swift
//  gloopdrop
//
//  Created by Michael Brünen on 18.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

/// This part of the GameScene class contains everything related to setting up the UI
extension GameScene {

    func setUpLabels() {
        // Score label
        scoreLabel.name = "score"
        scoreLabel.fontName = "Nosifer"
        scoreLabel.fontColor = .yellow
        scoreLabel.fontSize = 35.0
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = Layer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: viewTop() - 100)

        // set the text and add label to scene
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)

        // Level label
        levelLabel.name = "level"
        levelLabel.fontName = "Nosifer"
        levelLabel.fontColor = .yellow
        levelLabel.fontSize = 35.0
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = Layer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + 50, y: viewTop() - 100)

        // set the text and add label to scene
        levelLabel.text = "Level \(level)"
        addChild(levelLabel)
    }

    func setUpStartButton() {
        startGameButton.name = "start"
        startGameButton.setScale(0.55)
        startGameButton.zPosition = Layer.ui.rawValue
        startGameButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startGameButton)

        // add animation
        let scaleUp = SKAction.scale(to: 0.55, duration: 0.65)
        let scaleDown = SKAction.scale(to: 0.50, duration: 0.65)
        let playBounce = SKAction.sequence([scaleDown, scaleUp])
        let bounceRepeat = SKAction.repeatForever(playBounce)
        startGameButton.run(bounceRepeat)
    }

    func showStartButton() {
        let showAction = SKAction.fadeIn(withDuration: 0.25)
        startGameButton.run(showAction)
        if AdMobHelper.rewardAdReady {
            watchAdButton.run(showAction)
        }
    }

    func hideStartButton() {
        let hideAction = SKAction.fadeOut(withDuration: 0.25)
        startGameButton.run(hideAction)
        if AdMobHelper.rewardAdReady {
            watchAdButton.run(hideAction)
        }
    }

    func showMessage(_ message: String) {
        // set up message label
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(x: frame.midX,
                                        y: frame.midY + startGameButton.size.height / 2)
        messageLabel.zPosition = Layer.ui.rawValue
        messageLabel.numberOfLines = 2

        // set up attributed text
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SKColor(red: 251.0 / 255.0,
                                      green: 155.0 / 255.0,
                                      blue: 24.0 / 255.0,
                                      alpha: 1.0),
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Nosifer", size: 45.0)!,
            .paragraphStyle: paragraph
        ]
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)

        // add the label to the scene with a fade action
        messageLabel.run(.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }

    func hideMessage() {
        // remove message label if it exists
        enumerateChildNodes(withName: "//message") { (node, _) in
            node.run(.sequence([
                .fadeOut(withDuration: 0.25),
                .removeFromParent()
            ]))
        }
    }

}
