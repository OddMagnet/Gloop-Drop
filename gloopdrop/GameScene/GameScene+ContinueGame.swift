//
//  GameScene+ContinueGame.swift
//  gloopdrop
//
//  Created by Michael Brünen on 15.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import GameKit

/// This part of the GameScene class contains functions related to the continue mechanic
extension GameScene {
    /// Sets up the watchAd and continueGame buttons
    func setUpContinues() {
        watchAdButton.name = "watchAd"
        watchAdButton.setScale(0.75)
        watchAdButton.zPosition = Layer.ui.rawValue
        watchAdButton.position = CGPoint(x: startGameButton.frame.maxX + 75,
                                         y: startGameButton.frame.midY - 25)
        watchAdButton.alpha = 0.0
        addChild(watchAdButton)

        continueGameButton.name = "continue"
        continueGameButton.setScale(0.85)
        continueGameButton.zPosition = Layer.ui.rawValue
        continueGameButton.position = CGPoint(x: frame.maxX - 75,
                                              y: viewBottom() + 60)
        addChild(continueGameButton)

        updateContinueButton()
    }

    /// Updates the image for the continue button
    func updateContinueButton() {
        if numberOfFreeContinues > maxNumberOfContinues {
            let texture = SKTexture(imageNamed: "continueRemaining-max")
            continueGameButton.texture = texture
        } else {
            let texture = SKTexture(imageNamed: "continueRemaining-\(numberOfFreeContinues)")
            continueGameButton.texture = texture
        }
    }

    /// Checks if there are continues left and uses one
    func useContinue() {
        if numberOfFreeContinues > 0 {
            isContinue = true
            numberOfFreeContinues -= 1
            spawnMultipleGloops()
        }
    }
}
