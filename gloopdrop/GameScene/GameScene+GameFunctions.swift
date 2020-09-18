//
//  GameScene+GameFunctions.swift
//  gloopdrop
//
//  Created by Michael Brünen on 18.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

/// This part of the GameScene class contains the functions for the game routine
extension GameScene {
    
    // MARK: - Game functions
    func spawnMultipleGloops() {
        // hide message and start button
        hideMessage()
        hideStartButton()
        
        // start player animations
        player.walk()
        player.mumble()
        
        // reset level and score
        if gameInProgess == false && isContinue == false {
            score = 0
            level = 1
        } else {
            isContinue = false
        }
        
        // reset the collected drops count
        dropsCollected = 0
        
        // set the number for the drop label
        dropNumber = numberOfDrops
        
        // set up repeating action
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in
            self.spawnGloop()
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)
        
        // run action
        run(repeatAction, withKey: "gloop")
        
        // update game state
        gameInProgess = true
    }
    
    func spawnGloop() {
        let collectible = Collectible(collectibleType: .gloop)
        
        // set random position
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        var randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        
        /* start of enhanced drop pattern */
        // set a range
        let lowerLimit = 50 + CGFloat(level)
        let upperLimit = level <= 6
            ? 60 * CGFloat(level)
            : 400
        let modifierRange = SKRange(lowerLimit: lowerLimit,
                                    upperLimit: upperLimit)
        let modifier = CGFloat.random(in: modifierRange.lowerLimit...modifierRange.upperLimit)
        
        // set previous drop location
        if prevDropLocation == 0.0 {
            prevDropLocation = randomX
        }
        
        // clamp its x-position
        if prevDropLocation < randomX {
            randomX = prevDropLocation + modifier
        } else {
            randomX = prevDropLocation - modifier
        }
        
        // ensure the drop is within the frame
        if randomX < dropRange.lowerLimit { randomX = dropRange.lowerLimit }
        else if randomX > dropRange.upperLimit { randomX = dropRange.upperLimit }
        
        // store the location
        prevDropLocation = randomX
        /* end of enhanced drop pattern */
        
        // add number tag to the collectible
        let label = SKLabelNode()
        label.name = "dropNumber"
        label.fontName = "AvenirNext-DemiBold"
        label.fontColor = UIColor.yellow
        label.fontSize = 22.0
        label.text = String(dropNumber)
        label.position = CGPoint(x: 0, y: 2)
        collectible.addChild(label)
        
        // decrease dropnumber
        dropNumber -= 1
        
        // set up the drop
        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: 1.0, floorLevel: player.frame.minY)
    }
    
    func checkForRemainingDrops() {
        if dropsCollected == dropsExpected {
            //            print("next level")
            nextLevel()
        }
    }
    
    func nextLevel() {
        // show message
        showMessage("Get ready!")
        
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait, completion: { [unowned self] in
            self.level += 1
            self.spawnMultipleGloops()
        })
    }
    
    func gameOver() {
        // show message
        showMessage("Game Over\nStart a New Game or Continue")
        
        // update game state
        gameInProgess = false
        
        // start the player die animation
        player.die()
        
        // stop collectibles from spawning
        removeAction(forKey: "gloop")
        
        // check all child node, stop actions on collectibles
        enumerateChildNodes(withName: "//co_*") { (node, _) in
            // Stop and remove drops
            node.removeAction(forKey: "drop")
            node.physicsBody = nil
        }
        
        // Reset game
        resetPlayerPosition()
        popRemainingDrops()
        showStartButton()
        dropsCollected = 0
    }
    
    func resetPlayerPosition() {
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x - player.position.x, 0)
        let speed = TimeInterval(distance / (resetSpeed * 2)) / 255
        
        player.moveTo(resetPoint,
                      direction: player.position.x > frame.midX
                        ? .left
                        : .right,
                      speed: speed)
    }
    
    func popRemainingDrops() {
        var i = 0
        enumerateChildNodes(withName: "//co_*") { (node, stop) in
            // pop remaining drops in sequence
            let initialWait = SKAction.wait(forDuration: 1.0)
            let wait = SKAction.wait(forDuration: TimeInterval(0.15 * CGFloat(i)))
            let removeFromParent = SKAction.removeFromParent()
            let actionSequence = SKAction.sequence([initialWait, wait, removeFromParent])
            node.run(actionSequence)
            i += 1
        }
    }
    
}
