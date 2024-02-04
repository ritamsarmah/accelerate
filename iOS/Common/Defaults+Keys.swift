//
//  Constants.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/9/21.
//

import Defaults
import Foundation

extension Defaults {
    static let suite = UserDefaults(suiteName: "group.XXYXWGAW9Y.Accelerate")!
}

extension Defaults.Keys {
    // Array of shortcut preference keys
    static let allShortcutKeys: [Defaults.AnyKey] = [.shortcuts]
}
