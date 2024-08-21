//
//  SafariExtensionHandler.swift
//  Accelerate Extension
//
//  Created by Ritam Sarmah on 2/8/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Defaults
import MASShortcut
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    private static var snackbarIcons: [String: String] = {
        let filenames = ["backward", "forward", "loop", "mute", "pause", "pip", "play", "skip", "unmute"]
        var icons = [String: String]()

        for filename in filenames {
            let url = Bundle.main.url(forResource: filename, withExtension: "svg")!
            icons[filename] = try! String(contentsOf: url)
        }
        return icons
    }()

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo _: [String: Any]?) {
        switch messageName {
        case "shouldInitialize":
            // If app has not been launched yet, show tutorial window (and migrate existing preferences)
            if Defaults[.launchCount] == 0 {
                let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.ritamsarmah.Accelerate")!

                if #available(macOSApplicationExtension 10.15, *) {
                    NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                } else {
                    NSWorkspace.shared.open(url)
                }

                page.dispatchMessageToScript(withName: "upgrade", userInfo: nil)
            }

            page.isAllowed { isAllowed, rule in
                if isAllowed {
                    let shortcuts = Defaults[.shortcuts]
                        .filter { $0.isEnabled }
                        .map(\.dictionaryRepresentation)

                    self.registerGlobalShortcuts(for: page)

                    page.dispatchMessageToScript(
                        withName: "initialize",
                        userInfo: [
                            "shortcuts": shortcuts,
                            "defaultRate": Defaults[.defaultRate],
                            "minimumRate": Defaults[.minimumRate],
                            "maximumRate": Defaults[.maximumRate],
                            "snackbarLocation": Defaults[.snackbarLocation].description,
                            "snackbarIcons": SafariExtensionHandler.snackbarIcons,
                            "isVerboseLogging": _isDebugAssertConfiguration() || Defaults[.isVerboseLogging],
                        ]
                    )
                } else {
                    page.dispatchMessageToScript(withName: "blocked", userInfo: ["rule": rule ?? ""])
                }
            }
        case "didFocus":
            registerGlobalShortcuts(for: page)
        default:
            break
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        window.getActiveTab { tab in
            tab?.getActivePage { page in
                if let shortcutIndex = Defaults[.shortcuts].toolbarShortcutIndex {
                    page?.triggerAction(for: Defaults[.shortcuts][shortcutIndex])
                }
            }
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        window.getActiveTab { tab in
            tab?.getActivePage { page in
                page?.isAllowed { isAllowed, _ in
                    DispatchQueue.main.async { validationHandler(isAllowed, "") }
                }
            }
        }
    }

    override func validateContextMenuItem(withCommand command: String, in _: SFSafariPage, userInfo: [String: Any]? = nil, validationHandler: @escaping (Bool, String?) -> Void) {
        guard let userInfo,
            let isInitialized = userInfo["isInitialized"] as? Bool,
            let hasVideos = userInfo["hasVideos"] as? Bool,
            let currentRate = userInfo["currentRate"] as? Double
        else {
            validationHandler(true, nil)
            return
        }

        if !isInitialized || !hasVideos {
            validationHandler(true, nil)
            return
        }

        if let index = Int(command), Defaults[.shortcuts].indices ~= index {
            let shortcut = Defaults[.shortcuts][index]

            if shortcut.showInContextMenu {
                switch shortcut.action {
                case let .setRate(rate):
                    // Don't show context menu item for setRate actions if the current rate is already set to the associated value
                    validationHandler(currentRate == (rate ?? Defaults[.defaultRate]), shortcut.action.description)
                    return
                default:
                    validationHandler(false, shortcut.action.description)
                    return
                }
            }
        }

        validationHandler(true, nil)
    }

    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo _: [String: Any]? = nil) {
        if let index = Int(command), Defaults[.shortcuts].indices ~= index {
            let shortcut = Defaults[.shortcuts][index]
            page.triggerAction(for: shortcut)
        }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        SafariExtensionViewController.shared
    }

    /// Unregister any prior global shortcuts, and register them to provided page.
    private func registerGlobalShortcuts(for page: SFSafariPage) {
        if let monitor = MASShortcutMonitor.shared() {
            monitor.unregisterAllShortcuts()

            Defaults[.shortcuts]
                .filter { $0.isEnabled && $0.isGlobal }
                .forEach { shortcut in
                    let masShortcut = MASShortcut(keyCode: shortcut.keyCode, modifierFlags: shortcut.modifiers)

                    if !monitor.isShortcutRegistered(masShortcut) {
                        monitor.register(masShortcut) {
                            page.triggerAction(for: shortcut)
                        }
                    }
                }
        }
    }
}
