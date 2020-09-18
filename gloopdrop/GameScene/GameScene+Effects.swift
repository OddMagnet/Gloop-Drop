//
//  GameScene+Effects.swift
//  gloopdrop
//
//  Created by Michael Brünen on 18.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

extension GameScene {
    
    // MARK: - Particle & Extra effects
    func setUpGloopFlow() {
        let gloopFlow = SKNode()
        gloopFlow.name = "gloopFlow"
        gloopFlow.zPosition = Layer.foreground.rawValue
        gloopFlow.position = CGPoint(x: 0.0, y: -60.0)
        // start endless scroll
        gloopFlow.setUpScrollingView(imageNamed: "flow_1", layer: .foreground, emitterNamed: "GloopFlow.sks", blocks: 3, speed: 30.0)
        addChild(gloopFlow)
    }
    
    func setUpStars() {
        if let starEmitter = SKEmitterNode(fileNamed: "Stars.sks") {
            starEmitter.name = "stars"
            starEmitter.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(starEmitter)
        }
    }
    
    func sendRobots() {
        // set up robot
        let robot = SKSpriteNode(imageNamed: "robot")
        robot.zPosition = Layer.foreground.rawValue
        robot.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(robot)
        
        // decide from where to where the robot goes and set its starting position
        var start = CGPoint(x: frame.minX - robot.size.width,
                            y: frame.midY + robot.size.height)
        var end = CGPoint(x: frame.maxX + robot.size.width,
                          y: frame.midY + robot.size.height)
        let rightToLeft = Bool.random()
        if rightToLeft { (start, end) = (end, start); robot.xScale = -abs(xScale) }
        robot.position = CGPoint(x: start.x, y: start.y)
        
        // set up audio
        let robotAudio = SKAudioNode(fileNamed: "robot.wav")
        robotAudio.autoplayLooped = true
        robotAudio.run(.changeVolume(to: 1.0, duration: 0.0))
        robot.addChild(robotAudio)
        
        // sequence for wobbling up and down
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.25)
        let moveDown = SKAction.moveBy(x: 0, y: -20, duration: 0.25)
        let wobbleGroup = SKAction.sequence([moveUp, moveDown])
        let wobbleAction = SKAction.repeatForever(wobbleGroup)
        robot.run(wobbleAction)
        
        // actions for moving the robot across the screen and removing it from the scene
        let move = SKAction.moveTo(x: end.x, duration: 6.50)
        let removeFromParent = SKAction.removeFromParent()
        let moveSequence = SKAction.sequence([move, removeFromParent])
        
        // run the sequence and call this function periodically
        robot.run(moveSequence, completion: {
            let wait = SKAction.wait(forDuration: 30, withRange: 30)
            let sendNewRobot = SKAction.run(self.sendRobots)
            self.run(.sequence([wait, sendNewRobot]))
        })
    }
    
}
