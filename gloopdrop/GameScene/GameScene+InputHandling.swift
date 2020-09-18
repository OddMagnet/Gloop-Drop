//
//  GameScene+InputHandling.swift
//  gloopdrop
//
//  Created by Michael Brünen on 18.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

/// This part of the GameScene class contains the handling of user input
extension GameScene {

    /// Handles touch inputs
    ///
    /// Handles touch inputs for
    /// - moving the player
    /// - starting the game
    /// - watching an ad
    /// - using a continue
    /// - Parameter position: the position the touch(es) occured
    func touchDownAt(_ position: CGPoint) {
        let touchedNodes = nodes(at: position)
        for node in touchedNodes {
            if (node.name == "player" || node.name == "controller") && gameInProgess {
                movingPlayer = true
            } else if node == watchAdButton && !gameInProgess {
                gameSceneDelegate?.showRewardVideo()
                return
            } else if node == continueGameButton && !gameInProgess {
                print("Continue Button pressed")
                useContinue()
                return
            } else if node == startGameButton && !gameInProgess {
                spawnMultipleGloops()
            }
        }
    }

    /// Handles the moving of touches, aka dragging a finger across the screen
    ///
    /// Moves the player node across the screen and handles player direction
    /// - Parameter position: the position the touch(es) moved to
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

    /// Handles the stopping of a touch
    ///
    /// Stops player movement
    /// - Parameter position: the position the touch stopped at
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
