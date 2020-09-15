//
//  GameScene+ContinueGame.swift
//  gloopdrop
//
//  Created by Michael Brünen on 15.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import GameKit

extension GameScene {
    func setUpContinues() {
        watchAdButton.name = "watchAd"
        watchAdButton.setScale(0.75)
        watchAdButton.zPosition = Layer.ui.rawValue
        watchAdButton.position = CGPoint(x: startGameButton.frame.maxX + 75,
                                         y: startGameButton.frame.midY - 25)
        addChild(watchAdButton)

        continueGameButton.name = "continue"
        continueGameButton.setScale(0.85)
        continueGameButton.zPosition = Layer.ui.rawValue
        continueGameButton.position = CGPoint(x: frame.maxX - 75,
                                              y: viewBottom() + 60)
        addChild(continueGameButton)

        updateContinueButton()
    }

    func updateContinueButton() {
        if numberOfFreeContinues > maxNumberOfContinues {
            let texture = SKTexture(imageNamed: "continueRemaining-max")
            continueGameButton.texture = texture
        } else {
            let texture = SKTexture(imageNamed: "continueRemaining-\(numberOfFreeContinues)")
            continueGameButton.texture = texture
        }
    }
}
