//
//  GameScene.swift
//  gloopdrop
//
//  Created by Michael Brünen on 03.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    // MARK: - Properties
    // Player
    let player = Player()
    let playerMovementSpeed: CGFloat = 1.5
    var movingPlayer = false
    var lastPosition: CGPoint?
    // Game
    var gameInProgess = false
    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level \(level)"
        }
    }
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    var minDropSpeed: CGFloat = 0.12    // fastest drop speed
    var maxDropSpeed: CGFloat = 1.0     // slowest drop speed
    var dropsExpected: Int { return numberOfDrops }
    var dropsCollected: Int = 0
    // Labels
    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()
    // Audio
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")

    // MARK: - Computed properties
    var numberOfDrops: Int {
        switch level {
            case 1...5:
                return level * 10
            case 6:
                return 75
            case 7:
                return 100
            case 8:
                return 125
            default:
                return 150
        }
    }
    var dropSpeed: CGFloat {
        var speed = 1.1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if speed < minDropSpeed { speed = minDropSpeed }
        else if speed > maxDropSpeed { speed = maxDropSpeed }
        return speed
    }

    // MARK: - Init
    override func didMove(to view: SKView) {
        // decrease audio engine's volume for later fade-in
        audioEngine.mainMixerNode.outputVolume = 0.0

        // set up background music node
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        // and add it to the scene
        addChild(musicAudioNode)
        // adjust its volume
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0))
        // then fade it in slowly
        run(SKAction.wait(forDuration: 1.0), completion: { [unowned self] in
            self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.75, duration: 2.0))
        })

        // set up the physics world contact delegate
        physicsWorld.contactDelegate = self
        
        // set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.anchorPoint = .zero
        background.zPosition = Layer.background.rawValue
        background.position = .zero
        addChild(background)

        // set up foreground
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.anchorPoint = .zero
        foreground.zPosition = Layer.foreground.rawValue
        foreground.position = .zero
        // add physics body
        foreground.physicsBody = SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity = false
        addChild(foreground)

        // set up physics categories for contacts
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground        // set the category the foreground belongs to
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible    // only care about conact with collectibles
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none             // ignore collisions completely

        // set up user interface
        setUpLabels()

        // set up player
        // initially place the player sprite centered horizontally and on top of the foreground node
        player.position = CGPoint(x: size.width / 2, y: foreground.frame.maxY)
        player.setUpConstraints(floor: foreground.frame.maxY)
        addChild(player)
        // start up the player animation
//        player.walk()

        // set up game
//        spawnMultipleGloops()

        // show message
        showMessage("Tap to start the game")

    }

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

    func showMessage(_ message: String) {
        // set up message label
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(x: frame.midX, y: player.frame.maxY + 100)
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
//        if let messageLabel = childNode(withName: "//message") as? SKLabelNode {
//            messageLabel.run(.sequence([
//                .fadeOut(withDuration: 0.25),
//                .removeFromParent()
//            ]))
//        }
    }

    // MARK: - Game functions
    func spawnMultipleGloops() {
        // start the player walking animation
        player.walk()

        // reset level and score
        if gameInProgess == false {
            score = 0
            level = 1
        }

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

        // hide message
        hideMessage()
    }

    func spawnGloop() {
        let collectible = Collectible(collectibleType: .gloop)

        // set random position
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)

        // set up the drop
        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: 1.0, floorLevel: player.frame.minY)
    }

    func checkForRemainingDrops() {
        if dropsCollected == dropsExpected {
            print("next level")
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
        showMessage("Game Over\nTap to try again")

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
        dropsCollected = 0
    }

    func resetPlayerPosition() {
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x - player.position.x, 0)
        let speed = TimeInterval(distance / (playerMovementSpeed * 2)) / 255

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

    // MARK: - Touch input handling
    func touchDownAt(_ position: CGPoint) {
//        // calculate necessary speed based on current and new position
//        let distance = hypot(position.x - player.position.x, position.y - player.position.y)
//        let speed = TimeInterval(distance / playerMovementSpeed) / 255
//        let direction: PlayerDirection = position.x < player.position.x
//            ? .left
//            : .right
//        player.moveTo(position, direction: direction, speed: speed)
        if gameInProgess == false {
            spawnMultipleGloops()
            return
        }
        let touchedNode = atPoint(position)
        if touchedNode.name == "player" {
            movingPlayer = true
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
