//
//  ShortcutDetailViewModel.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/29/21.
//

import Defaults
import Foundation

extension ShortcutDetailView {

    class ViewModel: ObservableObject {

        @Published var actionDescription: String  // Use description since actions aren't equal if they have different associated values
        @Published var associatedValue: NSNumber!
        @Published var keyInput: String
        @Published var useDefaultSpeed: Bool
        @Published var showSnackbar: Bool
        @Published var showInPopup: Bool
        @Published var isEnabled: Bool  // NOTE: currently unimplemented in UI

        private var shortcut: Shortcut?
        private var lastValidKeyInput: String

        var isNewShortcut: Bool { shortcut == nil }

        var isValidShortcut: Bool {
            switch actionDescription {
            case "Skip Backward", "Skip Forward", "Slow Down", "Speed Up":
                associatedValue != nil
            default:
                true
            }
        }

        var title: String { isNewShortcut ? "New Shortcut" : "Edit Shortcut" }

        init(shortcut: Shortcut?) {
            self.shortcut = shortcut
            self.lastValidKeyInput = shortcut?.keyInput ?? ""

            if let shortcut {
                self.actionDescription = shortcut.action.defaultDescription
                self.associatedValue = shortcut.action.associatedValue ?? 1
                self.keyInput = shortcut.keyInput ?? ""
                self.useDefaultSpeed = shortcut.action == .setRate(nil)
                self.showSnackbar = shortcut.showSnackbar
                self.showInPopup = shortcut.showInPopup
                self.isEnabled = shortcut.isEnabled
            } else {
                self.actionDescription = Shortcut.Action.speedUp().defaultDescription
                self.associatedValue = 0.25
                self.keyInput = ""
                self.useDefaultSpeed = false
                self.showSnackbar = true
                self.showInPopup = true
                self.isEnabled = true
            }
        }

        func saveShortcut() {
            let action: Shortcut.Action =
                switch actionDescription {
                case "Speed Up": .speedUp(amount: associatedValue.doubleValue)
                case "Slow Down": .slowDown(amount: associatedValue.doubleValue)
                case "Toggle Speed": .setRate(useDefaultSpeed ? nil : associatedValue.doubleValue)
                case "Show Current Speed": .showRate
                case "Play/Pause": .playOrPause
                case "Skip Forward": .skipForward(seconds: associatedValue.intValue)
                case "Skip Backward": .skipBackward(seconds: associatedValue.intValue)
                case "Skip to End": .skipToEnd
                case "Toggle Mute": .toggleMute
                case "Toggle Picture in Picture": .pip
                case "Toggle Fullscreen": .fullscreen
                case "Toggle Looping": .loop
                default: fatalError("Unknown action description")
                }

            if let shortcut, let index = Defaults[.shortcuts].firstIndex(of: shortcut) {
                // Update existing shortcut
                Defaults[.shortcuts][index].action = action
                Defaults[.shortcuts][index].keyInput = keyInput
                Defaults[.shortcuts][index].showSnackbar = showSnackbar
                Defaults[.shortcuts][index].showInPopup = showInPopup
            } else {
                // Create new shortcut
                let newShortcut = Shortcut(action: action, keyInput: keyInput, showSnackbar: showSnackbar, showInPopup: showInPopup)
                Defaults[.shortcuts].append(newShortcut)
            }
        }

        func validateKeyInput(_: String) {
            if lastValidKeyInput == keyInput { return }

            if keyInput.count > 1 {
                // Set to newest character
                keyInput = lastValidKeyInput == String(keyInput.first!) ? String(keyInput.last!) : String(keyInput.first!)
            }

            keyInput = keyInput.uppercased()
            lastValidKeyInput = keyInput
        }
    }
}
