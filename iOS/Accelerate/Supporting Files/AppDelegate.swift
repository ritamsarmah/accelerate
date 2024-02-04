//
//  AppDelegate.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 8/22/21.
//

import Defaults
import StoreKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Enable drag to dismiss for all scroll views
        UIScrollView.appearance().keyboardDismissMode = .onDrag

        Defaults[.launchCount] += 1

        if let scene = window?.windowScene, Defaults[.launchCount] == 5 {
            SKStoreReviewController.requestReview(in: scene)
        }

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
