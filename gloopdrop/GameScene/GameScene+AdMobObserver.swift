//
//  GameScene+AdMobObserver.swift
//  gloopdrop
//
//  Created by Michael Brünen on 16.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import GoogleMobileAds

/// This part of the GameScene class contains the setup for AdMob observers
extension GameScene {
    /// Adds notification observers for the `.userDidEarnReward`, `.adDidOrWillPresent`and `.adDidOrWillDismiss` notifications
    func setUpAdMobObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.userDidEarnReward(_:)),
                                               name: .userDidEarnReward,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.adDidOrWillPresent),
                                               name: .adDidOrWillPresent,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.adDidOrWillDismiss),
                                               name: .adDidOrWillDismiss,
                                               object: nil)
    }

    /// Handles the `.userDidEarnReward` notification
    /// - Parameter reward: the reward given, currently unused
    @objc func userDidEarnReward(_ reward: GADAdReward) {
        numberOfFreeContinues += 1
    }

    /// Handles the `.adDidOrWillPresent` notification
    @objc func adDidOrWillPresent() {
        audioEngine.mainMixerNode.outputVolume = 0.0
        watchAdButton.alpha = 0.0
    }

    /// Handles the `.adDidOrWillDismiss` notification
    @objc func adDidOrWillDismiss() {
        audioEngine.mainMixerNode.outputVolume = 1.0
    }
}
