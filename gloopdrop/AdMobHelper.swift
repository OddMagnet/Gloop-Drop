//
//  AdMobHelper.swift
//  gloopdrop
//
//  Created by Tammy Coron on 1/24/2020.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import Foundation
import GoogleMobileAds

struct AdMobHelper {
    static let bannerAdDisplayTime: TimeInterval = 30
    static let bannerAdID = "ca-app-pub-3940256099942544/2934735716"
}

fileprivate var _adBannerView = GADBannerView(adSize: kGADAdSizeBanner)

extension GameViewController {
    // MARK: - Properties
    var adBannerView: GADBannerView {
        get {
            return _adBannerView
        }
        set {
            _adBannerView = newValue
        }
    }

    // set up banner ads
    func setUpBannerAdsWith(id: String) {
        // set up the banner view
        adBannerView.adUnitID = id
        adBannerView.delegate = self
        adBannerView.rootViewController = self

        // add it to the view
        addBannerViewToView(adBannerView)

        // start serving ads
        startServingAds(after: AdMobHelper.bannerAdDisplayTime)
    }

    // add the banner to a view
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        // set up constraints programmatically
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // start serving ads using a scheduled timer
    func startServingAds(after seconds: TimeInterval) {
        Timer.scheduledTimer(timeInterval: seconds,
                             target: self,
                             selector: #selector(requestAds(_:)),
                             userInfo: adBannerView,
                             repeats: false)
    }

    // start serving banner ads
    @objc func requestAds(_ timer: Timer) {
        let bannerView = timer.userInfo as? GADBannerView
        let request = GADRequest()
        bannerView?.load(request)

        timer.invalidate()
    }

    // hide banner
    @objc func hideBanner(_ timer: Timer) {
        let bannerView = timer.userInfo as! GADBannerView
        UIView.animate(withDuration: 0.5) {
            bannerView.alpha = 0.0
        }

        timer.invalidate()
    }
}

// MARK: - DELEGATE EXTENSIONS

/* ############################################################ */
/*             ADMOB DELEGATE FUNCTIONS STARTS HERE             */
/* ############################################################ */

extension GameViewController : GADBannerViewDelegate {
  
  // MARK: - GADBannerViewDelegate: Ad Request Lifecycle Notifications
  
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
    adBannerView = bannerView
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.adBannerView.alpha = 1.0
    })

    // auto-hide banner
    Timer.scheduledTimer(timeInterval: AdMobHelper.bannerAdDisplayTime,
                         target: self,
                         selector: #selector(hideBanner(_:)),
                         userInfo: bannerView,
                         repeats: false)
  }
  
  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
              didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }
  
  // MARK: - GADBannerViewDelegate: Click-Time Lifecycle Notifications
  
  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }
  
  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }
  
  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }
  
  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}

extension GameViewController: GADRewardedAdDelegate {
  
  // MARK: - GADRewardedAdDelegate: Lifecycle Notifications
  
  /// Tells the delegate that the user earned a reward.
  func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
    print("Reward received: \(reward.type) | amount: \(reward.amount).")
  }
  
  /// Tells the delegate that the rewarded ad was presented.
  func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
    print("Rewarded ad presented.")
  }
  
  /// Tells the delegate that the rewarded ad was dismissed.
  func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
    print("Rewarded ad dismissed.")
  }
  
  /// Tells the delegate that the rewarded ad failed to present.
  func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
    print("Rewarded ad failed to present.")
  }
}
