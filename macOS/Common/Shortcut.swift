//
//  Shortcut.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/14/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Carbon
import Defaults
import Foundation
import MASShortcut

struct Shortcut: Codable, Defaults.Serializable {

    /// The maximum number of shortcuts that can be created. This has been arbitrarily set based on number of context items available.
    static let maximumShortcuts = 30

    /// The default shortcuts initialized for new users.
    /// NOTE: We set identifier manually since Defaults will dynamically use this for defaultValue, which would otherwise generate new identifiers each launch.
    static let defaultShortcuts = [
        Shortcut(action: .speedUp(amount: 0.25), keyCode: kVK_ANSI_D, showInContextMenu: true, identifier: "B12238B1-61E1-4CBB-B1A1-8ADE0B7EA443"),
        Shortcut(action: .slowDown(amount: 0.25), keyCode: kVK_ANSI_S, showInContextMenu: true, identifier: "C1834E7B-BF7E-4F71-85D2-2487B6521080"),
        Shortcut(action: .setRate(nil), keyCode: kVK_ANSI_R, showInContextMenu: true, identifier: "0BE1D48E-7003-4069-8EE6-4832F1E08CC2"),
        Shortcut(action: .setRate(2), keyCode: kVK_ANSI_A, showInContextMenu: true, identifier: "FF7BF0BE-5DDC-4FFE-84CF-F5056A993A1A"),
        Shortcut(action: .showRate, keyCode: kVK_ANSI_V, identifier: "4B5FDD95-2B6E-4385-8867-CEC27C98E738"),
        Shortcut(action: .pip, keyCode: kVK_ANSI_P, identifier: "6D1C1680-C7E1-4AA1-86CA-456AF7B2E3E7"),
    ]

    /// The action triggered by the shortcut.
    var action: Action

    /// The virtual key code for the keyboard key.
    /// Hardware independent, same as in `NSEvent`. See `Events.h` in the HIToolbox framework for a complete list.
    var keyCode: Int

    /// One or modifier key flags that must be combined with the key code to trigger the action.
    var modifiers: NSEvent.ModifierFlags = []

    /// If true, shortcut is enabled.
    var isEnabled: Bool = true

    /// If true, shortcut can be activated globally, e.g., outside of Safari.
    var isGlobal: Bool = false

    /// If true, shows snackbar notification when triggered.
    var showSnackbar: Bool = true

    /// If true, shows action in right-click menu.
    var showInContextMenu: Bool = false

    // The unique identifier for this shortcut.
    var identifier: String = UUID().uuidString

    /// Dictionary representation of shortcut, primarily used by JavaScript extension.
    var dictionaryRepresentation: [String: Any?] {
        [
            "keyCombo": "\(Shortcut.javaScriptCodes[keyCode]!)\(modifiers)",
            "isEnabled": isEnabled,
            "isGlobal": isGlobal,
            "showSnackbar": showSnackbar,
            "showInContextMenu": showInContextMenu,
            "description": description,
        ].merging(action.dictionaryRepresentation) { current, _ in current }
    }
}

// MARK: - Shortcut Extensions

/// Based on https://github.com/sindresorhus/KeyboardShortcuts/blob/main/Sources/KeyboardShortcuts/Shortcut.swift
extension Shortcut: CustomStringConvertible {
    var description: String { action.description }

    var keyComboString: String {
        "\(modifiers)\(keyEquivalent)"
    }

    var keyEquivalent: String {
        keyToCharacter()?.localizedCapitalized ?? ""
    }

    fileprivate func keyToCharacter() -> String? {
        if let character = Shortcut.keyToCharacterMapping[keyCode] {
            return character
        }

        guard let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
            let layoutDataPointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        else {
            return nil
        }

        let layoutData = unsafeBitCast(layoutDataPointer, to: CFData.self)
        let keyLayout = unsafeBitCast(CFDataGetBytePtr(layoutData), to: UnsafePointer<CoreServices.UCKeyboardLayout>.self)
        var deadKeyState: UInt32 = 0
        let maxLength = 4
        var length = 0
        var characters = [UniChar](repeating: 0, count: maxLength)

        let error = CoreServices.UCKeyTranslate(
            keyLayout,
            UInt16(keyCode),
            UInt16(CoreServices.kUCKeyActionDisplay),
            0,  // No modifiers
            UInt32(LMGetKbdType()),
            OptionBits(CoreServices.kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            maxLength,
            &length,
            &characters
        )

        guard error == noErr else {
            return nil
        }

        return String(utf16CodeUnits: characters, count: length)
    }

    fileprivate static var keyToCharacterMapping: [Int: String] = [
        kVK_Return: "↩",
        kVK_Delete: "⌫",
        kVK_ForwardDelete: "⌦",
        kVK_End: "↘",
        kVK_Escape: "⎋",
        kVK_Help: "?⃝",
        kVK_Home: "↖",
        kVK_Space: "⎵",
        kVK_Tab: "⇥",
        kVK_PageUp: "⇞",
        kVK_PageDown: "⇟",
        kVK_UpArrow: "↑",
        kVK_RightArrow: "→",
        kVK_DownArrow: "↓",
        kVK_LeftArrow: "←",
        kVK_F1: "F1",
        kVK_F2: "F2",
        kVK_F3: "F3",
        kVK_F4: "F4",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12",
        kVK_F13: "F13",
        kVK_F14: "F14",
        kVK_F15: "F15",
        kVK_F16: "F16",
        kVK_F17: "F17",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_F20: "F20",
    ]

    // https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code/code_values
    fileprivate static var javaScriptCodes: [Int: String] = [
        kVK_ANSI_A: "KeyA",
        kVK_ANSI_S: "KeyS",
        kVK_ANSI_D: "KeyD",
        kVK_ANSI_F: "KeyF",
        kVK_ANSI_H: "KeyH",
        kVK_ANSI_G: "KeyG",
        kVK_ANSI_Z: "KeyZ",
        kVK_ANSI_X: "KeyX",
        kVK_ANSI_C: "KeyC",
        kVK_ANSI_V: "KeyV",
        kVK_ANSI_B: "KeyB",
        kVK_ANSI_Q: "KeyQ",
        kVK_ANSI_W: "KeyW",
        kVK_ANSI_E: "KeyE",
        kVK_ANSI_R: "KeyR",
        kVK_ANSI_Y: "KeyY",
        kVK_ANSI_T: "KeyT",
        kVK_ANSI_1: "Digit1",
        kVK_ANSI_2: "Digit2",
        kVK_ANSI_3: "Digit3",
        kVK_ANSI_4: "Digit4",
        kVK_ANSI_6: "Digit6",
        kVK_ANSI_5: "Digit5",
        kVK_ANSI_Equal: "Equal",
        kVK_ANSI_9: "Digit9",
        kVK_ANSI_7: "Digit7",
        kVK_ANSI_Minus: "Minus",
        kVK_ANSI_8: "Digit8",
        kVK_ANSI_0: "Digit0",
        kVK_ANSI_RightBracket: "BracketRight",
        kVK_ANSI_O: "KeyO",
        kVK_ANSI_U: "KeyU",
        kVK_ANSI_LeftBracket: "BracketLeft",
        kVK_ANSI_I: "KeyI",
        kVK_ANSI_P: "KeyP",
        kVK_ANSI_L: "KeyL",
        kVK_ANSI_J: "KeyJ",
        kVK_ANSI_Quote: "Quote",
        kVK_ANSI_K: "KeyK",
        kVK_ANSI_Semicolon: "Semicolon",
        kVK_ANSI_Backslash: "Backslash",
        kVK_ANSI_Comma: "Comma",
        kVK_ANSI_Slash: "Slash",
        kVK_ANSI_N: "KeyN",
        kVK_ANSI_M: "KeyM",
        kVK_ANSI_Period: "Period",
        kVK_ANSI_Grave: "Backquote",
        kVK_ANSI_KeypadDecimal: "NumpadDecimal",
        kVK_ANSI_KeypadMultiply: "NumpadMultiply",
        kVK_ANSI_KeypadPlus: "NumpadAdd",
        kVK_ANSI_KeypadClear: "NumLock",
        kVK_ANSI_KeypadDivide: "NumpadDivide",
        kVK_ANSI_KeypadEnter: "NumpadEnter",
        kVK_ANSI_KeypadMinus: "NumpadSubtract",
        kVK_ANSI_KeypadEquals: "NumpadEqual",
        kVK_ANSI_Keypad0: "Numpad0",
        kVK_ANSI_Keypad1: "Numpad1",
        kVK_ANSI_Keypad2: "Numpad2",
        kVK_ANSI_Keypad3: "Numpad3",
        kVK_ANSI_Keypad4: "Numpad4",
        kVK_ANSI_Keypad5: "Numpad5",
        kVK_ANSI_Keypad6: "Numpad6",
        kVK_ANSI_Keypad7: "Numpad7",
        kVK_ANSI_Keypad8: "Numpad8",
        kVK_ANSI_Keypad9: "Numpad9",
        kVK_Return: "Return",
        kVK_Tab: "Tab",
        kVK_Space: "Space",
        kVK_Delete: "Backspace",
        kVK_Escape: "Escape",
        kVK_Command: "OSLeft",
        kVK_Shift: "ShiftLeft",
        kVK_CapsLock: "CapsLock",
        kVK_Option: "AltLeft",
        kVK_Control: "ControlLeft",
        kVK_RightCommand: "OSRight",
        kVK_RightShift: "ShiftRight",
        kVK_RightOption: "AltRight",
        kVK_RightControl: "ControlRight",
        kVK_Function: "Fn",  // no events fired actually
        kVK_F17: "F17",
        kVK_VolumeUp: "AudioVolumeUp",
        kVK_VolumeDown: "AudioVolumeDown",
        kVK_Mute: "AudioVolumeMute",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_F20: "F20",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F3: "F3",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F11: "F11",
        kVK_F13: "F13",
        kVK_F16: "F16",
        kVK_F14: "F14",
        kVK_F10: "F10",
        kVK_F12: "F12",
        kVK_F15: "F15",
        kVK_Help: "Help",
        kVK_Home: "Home",
        kVK_PageUp: "PageUp",
        kVK_ForwardDelete: "Delete",
        kVK_F4: "F4",
        kVK_End: "End",
        kVK_F2: "F2",
        kVK_PageDown: "PageDown",
        kVK_F1: "F1",
        kVK_LeftArrow: "ArrowLeft",
        kVK_RightArrow: "ArrowRight",
        kVK_DownArrow: "ArrowDown",
        kVK_UpArrow: "ArrowUp",
        kVK_ISO_Section: "IntlBackslash",
        kVK_JIS_Yen: "IntlYen",
        kVK_JIS_Underscore: "IntlRo",
        kVK_JIS_KeypadComma: "NumpadComma",
        kVK_JIS_Eisu: "Lang2",
        kVK_JIS_Kana: "Lang1",
    ]
}

extension Shortcut {
    init(action: Action, masShortcut: MASShortcut) {
        self.init(action: action, keyCode: masShortcut.keyCode, modifiers: masShortcut.modifierFlags)
    }
}

extension Shortcut.Action {
    mutating func set(associatedValue value: Any? = nil) {
        switch self {
        case .speedUp:
            guard let amount = value as? Double else { fatalError() }
            self = .speedUp(amount: amount)
        case .slowDown:
            guard let amount = value as? Double else { fatalError() }
            self = .slowDown(amount: amount)
        case .setRate:
            guard let rate = value as? Double? else { fatalError() }
            self = .setRate(rate)
        case .skipForward:
            guard let seconds = value as? Int else { fatalError() }
            self = .skipForward(seconds: seconds)
        case .skipBackward:
            guard let seconds = value as? Int else { fatalError() }
            self = .skipBackward(seconds: seconds)
        default:
            break  // No associated value
        }
    }
}
