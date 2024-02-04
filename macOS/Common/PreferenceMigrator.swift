//
//  ShortcutMigrator.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/14/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Carbon
import Defaults
import Foundation
import MASShortcut

/// Assists transition of user preferences to new 4.0 version format
class PreferenceMigrator {

    static let shared = PreferenceMigrator()

    private static let legacyDefaultsSuiteName = "XXYXWGAW9Y.group.Accelerate"
    private let legacyDefaults = UserDefaults(suiteName: legacyDefaultsSuiteName)!

    private let keysForString: [String: (Int, NSEvent.ModifierFlags)] = [
        "A": (kVK_ANSI_A, []),
        "S": (kVK_ANSI_S, []),
        "D": (kVK_ANSI_D, []),
        "F": (kVK_ANSI_F, []),
        "H": (kVK_ANSI_H, []),
        "G": (kVK_ANSI_G, []),
        "Z": (kVK_ANSI_Z, []),
        "X": (kVK_ANSI_X, []),
        "C": (kVK_ANSI_C, []),
        "V": (kVK_ANSI_V, []),
        "B": (kVK_ANSI_B, []),
        "Q": (kVK_ANSI_Q, []),
        "W": (kVK_ANSI_W, []),
        "E": (kVK_ANSI_E, []),
        "R": (kVK_ANSI_R, []),
        "Y": (kVK_ANSI_Y, []),
        "T": (kVK_ANSI_T, []),
        "1": (kVK_ANSI_1, []),
        "2": (kVK_ANSI_2, []),
        "3": (kVK_ANSI_3, []),
        "4": (kVK_ANSI_4, []),
        "6": (kVK_ANSI_6, []),
        "5": (kVK_ANSI_5, []),
        "=": (kVK_ANSI_Equal, []),
        "9": (kVK_ANSI_9, []),
        "7": (kVK_ANSI_7, []),
        "-": (kVK_ANSI_Minus, []),
        "8": (kVK_ANSI_8, []),
        "0": (kVK_ANSI_0, []),
        "]": (kVK_ANSI_RightBracket, []),
        "O": (kVK_ANSI_O, []),
        "U": (kVK_ANSI_U, []),
        "[": (kVK_ANSI_LeftBracket, []),
        "I": (kVK_ANSI_I, []),
        "P": (kVK_ANSI_P, []),
        "L": (kVK_ANSI_L, []),
        "J": (kVK_ANSI_J, []),
        "'": (kVK_ANSI_Quote, []),
        "K": (kVK_ANSI_K, []),
        ";": (kVK_ANSI_Semicolon, []),
        "\\": (kVK_ANSI_Backslash, []),
        ",": (kVK_ANSI_Comma, []),
        "/": (kVK_ANSI_Slash, []),
        "N": (kVK_ANSI_N, []),
        "M": (kVK_ANSI_M, []),
        ".": (kVK_ANSI_Period, []),
        "`": (kVK_ANSI_Grave, []),

        "!": (kVK_ANSI_1, .shift),
        "@": (kVK_ANSI_2, .shift),
        "#": (kVK_ANSI_3, .shift),
        "$": (kVK_ANSI_4, .shift),
        "^": (kVK_ANSI_6, .shift),
        "%": (kVK_ANSI_5, .shift),
        "+": (kVK_ANSI_Equal, .shift),
        "(": (kVK_ANSI_9, .shift),
        "&": (kVK_ANSI_7, .shift),
        "_": (kVK_ANSI_Minus, .shift),
        "*": (kVK_ANSI_8, .shift),
        ")": (kVK_ANSI_0, .shift),
        "\"": (kVK_ANSI_Quote, .shift),
        ":": (kVK_ANSI_Semicolon, .shift),
        "|": (kVK_ANSI_Backslash, .shift),
        "<": (kVK_ANSI_Comma, .shift),
        "?": (kVK_ANSI_Slash, .shift),
        ">": (kVK_ANSI_Period, .shift),
        "~": (kVK_ANSI_Grave, .shift),
    ]

    var isLegacyDefaultsEmpty: Bool {
        !LegacyPreference.allCases.map { legacyDefaults.object(forKey: $0.rawValue) == nil }.contains(false)
            && !LegacyPreference.Number.allCases.map { legacyDefaults.object(forKey: $0.rawValue) == nil }.contains(false)
            && !LegacyPreference.SingleShortcut.allCases.map { legacyDefaults.object(forKey: $0.rawValue) == nil }.contains(false)
            && !LegacyPreference.ModifierShortcut.allCases.map { legacyDefaults.object(forKey: $0.rawValue) == nil }.contains(false)
    }

    // We need to compare using the debug description, since having a different associated value will return as inequal
    private let rateActions: [String] = {
        let actions: [Shortcut.Action] = [.speedUp(), .slowDown(), .setRate(), .showRate]
        return actions.map(\.debugDescription)
    }()

    private let playbackActions: [String] = {
        let actions: [Shortcut.Action] = [.playOrPause, .skipForward(), .skipBackward(), .skipToEnd, .toggleMute, .pip]
        return actions.map(\.debugDescription)
    }()

    private let defaultContextMenuActions: [String] = {
        let actions: [Shortcut.Action] = [.speedUp(), .slowDown(), .setRate()]
        return actions.map(\.debugDescription)
    }()

    func migrate() {
        // Skip migration if legacy defaults is empty
        if isLegacyDefaultsEmpty { return }

        Defaults[.defaultRate] = number(forKey: .defaultSpeed)

        if let value = preference(forKey: .snackbarLocation) as? Int {
            Defaults[.snackbarLocation] = SnackbarLocation(rawValue: value) ?? .topCenter
        }

        if let value = preference(forKey: .blocklist) as? [String] {
            Defaults[.blocklist] = value
        }

        if let value = preference(forKey: .invertBlocklist) as? Bool {
            Defaults[.isBlocklistInverted] = value
        }

        // Clear the default shortcuts before migration
        Defaults[.shortcuts].removeAll()

        LegacyPreference.SingleShortcut.allCases.forEach {
            let action = self.action(forSingleShortcut: $0)

            if let legacyShortcut = legacyDefaults.string(forKey: $0.rawValue), legacyShortcut != "",
                let (keyCode, modifiers) = keysForString[legacyShortcut]
            {
                createShortcut(action: action, keyCode: keyCode, modifiers: modifiers)
            }
        }

        // Convert modifier shortcut (only if a corresponding single shortcut doesn't already exist for a given action type)
        LegacyPreference.ModifierShortcut.allCases.forEach {
            // Format [keyCode: Int, modifierKeys: String]
            if let legacyShortcut = legacyDefaults.array(forKey: $0.rawValue),
                let keyCode = legacyShortcut[0] as? Int,
                let legacyModifiers = legacyShortcut[1] as? String, keyCode != 0
            {  // No value set
                let action = self.action(forModifierShortcut: $0)

                var modifiers: NSEvent.ModifierFlags = []
                legacyModifiers.unicodeScalars.forEach {
                    switch $0 {
                    case UnicodeScalar(kCommandUnicode)!:
                        modifiers.insert(.command)
                    case UnicodeScalar(kControlUnicode)!:
                        modifiers.insert(.control)
                    case UnicodeScalar(kOptionUnicode)!:
                        modifiers.insert(.option)
                    case UnicodeScalar(kShiftUnicode)!:
                        modifiers.insert(.shift)
                    default:
                        break
                    }
                }

                createShortcut(action: action, keyCode: keyCode, modifiers: modifiers)
            }
        }

        // If we've got a non-default Toggle Speed shortcut, set the toolbar action to it, else it should be empty
        Defaults[.toolbarShortcutIdentifier] = nil
        Defaults[.shortcuts].forEach {
            if case let .setRate(rate) = $0.action, rate != nil {
                Defaults[.toolbarShortcutIdentifier] = $0.identifier
            }
        }

        // We remove suite by calling the methods on UserDefaults.standard
        UserDefaults.standard.removePersistentDomain(forName: PreferenceMigrator.legacyDefaultsSuiteName)
        UserDefaults.standard.removeSuite(named: PreferenceMigrator.legacyDefaultsSuiteName)

        UserDefaults.standard.removeAll()  // Remove any settings related to MASShortcut
    }

    private func createShortcut(action: Shortcut.Action, keyCode: Int, modifiers: NSEvent.ModifierFlags) {
        // Enable showing snackbar if speed action, or if general playback notifications were enabled
        let shouldShowSnackbar =
            rateActions.contains(action.debugDescription)
            || (playbackActions.contains(action.debugDescription) && (preference(forKey: .generalSnackbarVisible) as? Bool ?? false))

        let shouldShowInContextMenu = defaultContextMenuActions.contains(action.debugDescription)

        let shortcut = Shortcut(
            action: action,
            keyCode: keyCode,
            modifiers: modifiers,
            showSnackbar: shouldShowSnackbar,
            showInContextMenu: shouldShowInContextMenu
        )

        Defaults[.shortcuts].append(shortcut)
    }

    private func preference(forKey key: LegacyPreference) -> Any? {
        legacyDefaults.object(forKey: key.rawValue)
    }

    private func number(forKey key: LegacyPreference.Number) -> Double {
        legacyDefaults.double(forKey: key.rawValue)
    }

    private func action(forModifierShortcut shortcut: LegacyPreference.ModifierShortcut) -> Shortcut.Action {
        switch shortcut {
        case .speedUp:
            .speedUp(amount: number(forKey: .rateChange))
        case .slowDown:
            .slowDown(amount: number(forKey: .rateChange))
        case .defaultSpeed:
            .setRate(nil)
        case .preferredSpeed:
            .setRate(number(forKey: .preferredSpeed))
        case .showSpeed:
            .showRate
        case .play:
            .playOrPause
        case .forward:
            .skipForward(seconds: Int(number(forKey: .skipAmount)))
        case .backward:
            .skipBackward(seconds: Int(number(forKey: .skipAmount)))
        case .skipEnd:
            .skipToEnd
        case .mute:
            .toggleMute
        case .pip:
            .pip
        }
    }

    private func action(forSingleShortcut shortcut: LegacyPreference.SingleShortcut) -> Shortcut.Action {
        switch shortcut {
        case .speedUp:
            .speedUp(amount: number(forKey: .rateChange))
        case .slowDown:
            .slowDown(amount: number(forKey: .rateChange))
        case .defaultSpeed:
            .setRate(nil)
        case .preferredSpeed:
            .setRate(number(forKey: .preferredSpeed))
        case .showSpeed:
            .showRate
        case .play:
            .playOrPause
        case .forward:
            .skipForward(seconds: Int(number(forKey: .skipAmount)))
        case .backward:
            .skipBackward(seconds: Int(number(forKey: .skipAmount)))
        case .skipEnd:
            .skipToEnd
        case .mute:
            .toggleMute
        case .pip:
            .pip
        }
    }

    private init() {}

    private enum LegacyPreference: String, CaseIterable {
        case contextMenuHidden
        case generalSnackbarVisible
        case snackbarLocation
        case blocklist
        case invertBlocklist

        enum ModifierShortcut: String, CaseIterable {
            case speedUp
            case slowDown
            case defaultSpeed = "default"
            case preferredSpeed = "preferred"
            case showSpeed

            case play
            case forward
            case backward
            case skipEnd
            case mute
            case pip
        }

        enum SingleShortcut: String, CaseIterable {
            case speedUp = "speedUpKey"
            case slowDown = "slowDownKey"
            case defaultSpeed = "defaultKey"
            case preferredSpeed = "preferredKey"
            case showSpeed = "showSpeedKey"

            case play = "playKey"
            case forward = "forwardKey"
            case backward = "backwardKey"
            case skipEnd = "skipEndKey"
            case mute = "muteKey"
            case pip = "pipKey"
        }

        enum Number: String, CaseIterable {
            case rateChange
            case defaultSpeed
            case preferredSpeed
            case skipAmount
        }
    }
}
