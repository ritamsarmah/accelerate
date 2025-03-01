//
//  AppDelegate.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/8/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import MASShortcut
import Preferences
import StoreKit

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let shortcuts = Self("shortcuts")
    static let blocklist = Self("blocklist")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet private var window: NSWindow!

    var preferencesStyle: Preferences.Style {
        if #available(macOS 11.0, *) {
            .toolbarItems
        } else {
            .segmentedControl
        }
    }

    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralViewController(),
            ShortcutsViewController(),
            BlocklistViewController(),
        ],
        style: preferencesStyle
    )

    func applicationDidFinishLaunching(_: Notification) {
        StoreManager.shared.completeTransactions()

        if Defaults[.launchCount] == 0 {
            showTutorialWindow()
        } else {
            preferencesWindowController.show(preferencePane: .general)
        }

        Defaults[.launchCount] += 1

        if #available(macOS 10.14, *), Defaults[.launchCount] == 5 {
            SKStoreReviewController.requestReview()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func showTutorialWindow() {
        window = NSWindow(contentViewController: TutorialViewController())
        window.title = "Tutorial"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.remove(.resizable)
        window.makeKeyAndOrderFront(nil)
    }

    @IBAction func openHelp(_: NSMenuItem) {
        let url = URL(string: "https://ritam.me/projects/accelerate/faq-mac")!
        NSWorkspace.shared.open(url)
    }

    @IBAction func openPrivacy(_: NSMenuItem) {
        let url = URL(string: "https://ritam.me/projects/accelerate/privacy")!
        NSWorkspace.shared.open(url)
    }

    @IBAction func openIssues(_: NSMenuItem) {
        let url = URL(string: "https://github.com/ritamsarmah/accelerate/issues")!
        NSWorkspace.shared.open(url)
    }

    @IBAction func openContact(_: NSMenuItem) {
        let url = URL(string: "mailto:hello@ritam.me")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func openGitHub(_: NSMenuItem) {
        let url = URL(string: "https://github.com/ritamsarmah/accelerate")!
        NSWorkspace.shared.open(url)
    }
}
