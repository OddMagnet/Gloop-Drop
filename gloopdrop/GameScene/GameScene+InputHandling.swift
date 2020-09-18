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
    
    // MARK: - Touch input handling
    func touchDownAt(_ position: CGPoint) {
        //        // calculate necessary speed based on current and new position
        //        let distance = hypot(position.x - player.position.x, position.y - player.position.y)
        //        let speed = TimeInterval(distance / playerMovementSpeed) / 255
        //        let direction: PlayerDirection = position.x < player.position.x
        //            ? .left
        //            : .right
        //        player.moveTo(position, direction: direction, speed: speed)
        
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
