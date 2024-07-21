//
//  Shortcut.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/3/21.
//

import Defaults
import UIKit

struct Shortcut: Codable, Defaults.Serializable, Equatable, Identifiable {

    /// The maximum number of shortcuts that can be created.
    static let maximumShortcuts = 30

    /// The default shortcuts initialized for new users.
    /// NOTE: We set identifier manually since Defaults will dynamically use this for defaultValue, which would otherwise generate new identifiers each launch.
    static let defaultShortcuts = [
        Shortcut(action: .speedUp(amount: 0.25), keyInput: "D", id: "B12238B1-61E1-4CBB-B1A1-8ADE0B7EA443"),
        Shortcut(action: .slowDown(amount: 0.25), keyInput: "S", id: "C1834E7B-BF7E-4F71-85D2-2487B6521080"),
        Shortcut(action: .setRate(nil), keyInput: "R", id: "0BE1D48E-7003-4069-8EE6-4832F1E08CC2"),
        Shortcut(action: .setRate(2), keyInput: "A", id: "FF7BF0BE-5DDC-4FFE-84CF-F5056A993A1A"),
        Shortcut(action: .skipForward(seconds: 10), keyInput: "X", id: "4FA1FD05-E821-4584-8F98-55DE9A5B17A2"),
        Shortcut(action: .skipBackward(seconds: 10), keyInput: "Z", id: "8D7B2F03-8F28-4F2B-A408-DDA504005DF3"),
        Shortcut(action: .showRate, keyInput: "V", showInPopup: false, id: "4B5FDD95-2B6E-4385-8867-CEC27C98E738"),
        Shortcut(action: .pip, keyInput: "P", id: "6D1C1680-C7E1-4AA1-86CA-456AF7B2E3E7"),
    ]

    /// The action triggered by the shortcut.
    var action: Action

    /// The input character to trigger action.
    var keyInput: String?

    /// If true, shortcut is enabled.
    var isEnabled: Bool = true

    /// If true, shows snackbar notification when triggered.
    var showSnackbar: Bool = true

    /// If true, shows shortcut in extension popup menu.
    var showInPopup: Bool = true

    // The unique identifier for this shortcut.
    var id: String = UUID().uuidString

    /// Dictionary representation of shortcut, primarily used by JavaScript extension.
    var dictionaryRepresentation: [String: Any?] {
        [
            "id": id,
            "keyCombo": keyInput,
            "isEnabled": isEnabled,
            "showSnackbar": showSnackbar,
            "showInPopup": showInPopup,
            "description": description,
        ].merging(action.dictionaryRepresentation) { current, _ in current }
    }

    var description: String {
        "\(action)"
    }
}

// MARK: - Action Extensions

extension Shortcut.Action {
    var iconSystemName: String {
        switch self {
        case .speedUp: "hare"
        case .slowDown: "tortoise"
        case .setRate: "speedometer"
        case .showRate: "eye"
        case .playOrPause: "playpause"
        case .skipForward: "goforward"
        case .skipBackward: "gobackward"
        case .skipToEnd: "forward.end"
        case .toggleMute: "speaker.slash"
        case .pip: "pip"
        case .fullscreen: "arrow.up.left.and.arrow.down.right"
        case .loop: "point.forward.to.point.capsulepath"
        }
    }
}

// TODO: Join this logic with macOS
extension Shortcut.Action {

    /// Use for binding get/set to associated value
    var associatedValue: NSNumber? {
        get {
            switch self {
            case let .slowDown(amount), let .speedUp(amount):
                NSNumber(value: amount)
            case let .setRate(rate):
                if let rate {
                    NSNumber(value: rate)
                } else {
                    nil
                }
            case let .skipBackward(seconds), let .skipForward(seconds):
                NSNumber(value: seconds)
            default:
                nil
            }
        }

        set {
            switch self {
            case .speedUp:
                guard let amount = newValue else { break }
                self = .speedUp(amount: amount.doubleValue)
            case .slowDown:
                guard let amount = newValue else { break }
                self = .slowDown(amount: amount.doubleValue)
            case .setRate:
                self = .setRate(newValue?.doubleValue)
            case .skipForward:
                guard let seconds = newValue else { break }
                self = .skipForward(seconds: seconds.intValue)
            case .skipBackward:
                guard let seconds = newValue else { break }
                self = .skipBackward(seconds: seconds.intValue)
            default:
                break  // No associated value
            }
        }
    }
}
