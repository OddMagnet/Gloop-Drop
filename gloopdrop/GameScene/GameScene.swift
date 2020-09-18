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

protocol GameSceneDelegate: AnyObject {
    func showRewardVideo()
}

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
    var prevDropLocation: CGFloat = 0.0
    var dropsExpected: Int { return numberOfDrops }
    var dropsCollected: Int = 0
    // Labels
    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()
    var dropNumber: Int = 0
    // Audio
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")
    let bubblesAudioNode = SKAudioNode(fileNamed: "bubbles.mp3")
    // UI
    let startGameButton = SKSpriteNode(imageNamed: "start")
    let watchAdButton = SKSpriteNode(imageNamed: "watchAd")
    let continueGameButton = SKSpriteNode(imageNamed: "continueRemaining-0")
    let maxNumberOfContinues = 6
    var numberOfFreeContinues: Int {
        get {
            return GameData.shared.freeContinues
        }
        set {
            GameData.shared.freeContinues = newValue
            updateContinueButton()
        }
    }
    var isContinue: Bool = false
    // Delegate
    weak var gameSceneDelegate: GameSceneDelegate?

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
        let speed = 1.1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if speed < minDropSpeed { return minDropSpeed }
        else if speed > maxDropSpeed { return maxDropSpeed }
        return speed
    }

    // MARK: - Init
    override func didMove(to view: SKView) {
        // set up notification observers
        setUpAdMobObservers()

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

        // Run a delayed action to add bubble audio to the scene
        run(SKAction.wait(forDuration: 1.5), completion:  { [unowned self] in
            self.bubblesAudioNode.autoplayLooped = true
            self.addChild(self.bubblesAudioNode)
        })

        // set up the physics world contact delegate
        physicsWorld.contactDelegate = self
        
        // set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.name = "background"
        background.anchorPoint = .zero
        background.zPosition = Layer.background.rawValue
        background.position = .zero
        addChild(background)

        // set up foreground
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.name = "foreground"
        foreground.anchorPoint = .zero
        foreground.zPosition = Layer.foreground.rawValue
        foreground.position = .zero
        // add physics body
        foreground.physicsBody = SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity = false
        addChild(foreground)

        // set up the banner
        let banner = SKSpriteNode(imageNamed: "banner")
        banner.zPosition = Layer.background.rawValue + 1
        banner.position = CGPoint(x: frame.midX, y: viewTop() - 20)
        banner.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addChild(banner)

        // set up physics categories for contacts
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground        // set the category the foreground belongs to
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible    // only care about conact with collectibles
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none             // ignore collisions completely

        // set up user interface
        setUpLabels()
        setUpStartButton()
        setUpContinues()

        // set up player
        // initially place the player sprite centered horizontally and on top of the foreground node
        player.position = CGPoint(x: size.width / 2, y: foreground.frame.maxY)
        player.setUpConstraints(floor: foreground.frame.maxY)
        addChild(player)
        // start up the player animation
//        player.walk()

        // set up game
//        spawnMultipleGloops()

        // set up gloop flow
        setUpGloopFlow()

        // set up stars
        setUpStars()

        // start sending robots
        let wait = SKAction.wait(forDuration: 30, withRange: 30)
        let startSendingRobots = SKAction.run(self.sendRobots)
        run(.sequence([wait, startSendingRobots]))

        // show message
        showMessage("Tap start to Play the Game")
    }
}
