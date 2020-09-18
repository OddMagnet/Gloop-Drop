//
//  GameScene+AdMobObserver.swift
//  gloopdrop
//
//  Created by Michael Brünen on 16.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension GameScene {
    func setUpAdMobObservers() {
        // Add notification observers
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

    @objc func userDidEarnReward(_ reward: GADAdReward) {
        numberOfFreeContinues += 1
    }

    @objc func adDidOrWillPresent() {
        audioEngine.mainMixerNode.outputVolume = 0.0
        watchAdButton.alpha = 0.0
    }

    @objc func adDidOrWillDismiss() {
        audioEngine.mainMixerNode.outputVolume = 1.0
    }
}
