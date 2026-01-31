//
//  Defaults+Keys.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/5/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Carbon
import Defaults
import Foundation

extension Defaults {
    static let suite = UserDefaults(suiteName: "XXYXWGAW9Y.group.Accelerate.v4")!
}

extension Defaults.Keys {
    // Identifier of shortcut associated with the toolbar
    static let toolbarShortcutIdentifier = Key<String?>("toolbarShortcut", default: nil, suite: Defaults.suite)

    // Array of shortcut preference keys
    static let allShortcutKeys: [Defaults.Keys] = [.shortcuts, .toolbarShortcutIdentifier]
}

extension [Shortcut] {
    var toolbarShortcutIndex: Int? {
        guard let toolbarShortcutIdentifier = Defaults[.toolbarShortcutIdentifier] else { return nil }
        return Defaults[.shortcuts].firstIndex(where: { $0.id == toolbarShortcutIdentifier })
    }
}
