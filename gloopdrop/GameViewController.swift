//
//  GameViewController.swift
//  gloopdrop
//
//  Created by Michael Brünen on 03.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create scene view which will present the scene
        if let view = self.view as! SKView? {
            // Create the scene
            let scene = GameScene(size: CGSize(width: 1336, height: 1024))
            scene.gameSceneDelegate = self

            // set the scale mode
            scene.scaleMode = .aspectFill

            // set background color
            scene.backgroundColor = UIColor(red: 105/255,
                                            green: 157/255,
                                            blue: 181/255,
                                            alpha: 1.0)

            // present the scene
            view.presentScene(scene)

            // set view options
//            view.ignoresSiblingOrder = false
//            view.showsPhysics = true
//            view.showsFPS = true
//            view.showsNodeCount = true

            // start showing ads
            setUpBannerAdsWith(id: AdMobHelper.bannerAdTestID)
            setUpRewardedAdsWith(id: AdMobHelper.rewardAdTestID)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GameSceneDelegate {
    func showRewardVideo() {
        if rewardedAdView?.isReady == true {
            rewardedAdView?.present(fromRootViewController: self, delegate: self)
        }
    }
}
