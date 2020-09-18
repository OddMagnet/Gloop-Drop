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

/// This part of the GameScene class contains all properties and the initialization of the game
/// About computed properties: Their comments are put in a way that displays same at the same height as others if the computed properties are collapsed
class GameScene: SKScene {
    // MARK: - Player
    let player = Player()                           // The player node
    let resetSpeed: CGFloat = 1.5                   // constant that dictates how fast the player resets after failing a Level
    var movingPlayer = false                        // set to true when the player node is touched, up until the touch ends.
    var lastPosition: CGPoint?                      // used to check against new position to determine direction of the player node

    // MARK: - Game
    var gameInProgess = false                       // used to check if player should be able to move, if score&level need to be reset
                                                    // and if certain UI Elements should show
    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level \(level)"
        }
    }                       // sets the text for the levelLabel
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }                       // sets the text for the scoreLabel
    var minDropSpeed: CGFloat = 0.12                // constant that dictates the fastest possible drop speed
    var maxDropSpeed: CGFloat = 1.0                 // constant that dictates the slowest possible drop speed
    var dropSpeed: CGFloat {
        let speed = 1.1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if speed < minDropSpeed { return minDropSpeed }
        else if speed > maxDropSpeed { return maxDropSpeed }
        return speed
    }                   // computed property that returns the drop speed for the current level
    var prevDropLocation: CGFloat = 0.0             // used to ensure that drops are not too far apart
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
    }                   // computed property that returns the number of drops for the current level
    var dropsExpected: Int { return numberOfDrops } // computed property that returns the drops expected to be caught to advance the current level
    var dropsCollected: Int = 0                     // counter for the current amount of collected drops
    var dropNumber: Int = 0                         // used to display the number of the falling drops
    let maxNumberOfContinues = 6                    // constant that dictactes how many free continues a player can have
    var numberOfFreeContinues: Int {
        get {
            return GameData.shared.freeContinues
        }
        set {
            GameData.shared.freeContinues = newValue
            updateContinueButton()
        }
    }           // computed property that saves and load the amount of free continues
    var isContinue: Bool = false                    // used to ensure that score and level don't get reset when the player uses a continue

    // MARK: - Nodes
    // Audio nodes
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")
    let bubblesAudioNode = SKAudioNode(fileNamed: "bubbles.mp3")
    // Label nodes
    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()
    // Sprites
    let startGameButton = SKSpriteNode(imageNamed: "start")
    let watchAdButton = SKSpriteNode(imageNamed: "watchAd")
    let continueGameButton = SKSpriteNode(imageNamed: "continueRemaining-0")

    // MARK: - Delegate
    weak var gameSceneDelegate: GameSceneDelegate?


    // MARK: - Init
    override func didMove(to view: SKView) {
        // MARK: Ads
        setUpAdMobObservers()


        // MARK: Audio
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


        // MARK: Sprites
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


        // MARK: Physics
        // set up the physics world contact delegate
        physicsWorld.contactDelegate = self

        // set up physics categories for contacts
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground        // set the category the foreground belongs to
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible    // only care about conact with collectibles
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none             // ignore collisions completely


        //MARK: UI
        setUpLabels()
        setUpStartButton()
        setUpContinues()


        // MARK: Player
        // initially place the player sprite centered horizontally and on top of the foreground node
        player.position = CGPoint(x: size.width / 2, y: foreground.frame.maxY)
        player.setUpConstraints(floor: foreground.frame.maxY)
        addChild(player)


        // MARK: Effects
        setUpGloopFlow()
        setUpStars()
        // start sending robots
        let wait = SKAction.wait(forDuration: 30, withRange: 30)
        let startSendingRobots = SKAction.run(self.sendRobots)
        run(.sequence([wait, startSendingRobots]))


        // MARK: Game Start
        showMessage("Tap start to Play the Game")
    }
}
