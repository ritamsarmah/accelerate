//
//  Defaults+Shared.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/21/22.
//

import Defaults
import Foundation

extension Defaults.Keys {
    // Tracks number of application launches
    static let launchCount = Key<Int>("launchCount", default: 0, suite: Defaults.suite)

    // If true, enable verbose logging to JavaScript console
    static let isVerboseLogging = Key<Bool>("isVerboseLogging", default: false, suite: Defaults.suite)

    // Array of all shortcuts
    static let shortcuts = Key<[Shortcut]>("shortcuts", default: Shortcut.defaultShortcuts, suite: Defaults.suite)

    // Default rate to start playing videos at
    static let defaultRate = Key<Double>("defaultRate", default: 1, suite: Defaults.suite)

    // Minimum rate that videos can play at
    static let minimumRate = Key<Double>("minimumRate", default: 0.25, suite: Defaults.suite)

    // Maximum rate that videos can play at
    static let maximumRate = Key<Double>("maximumRate", default: 16, suite: Defaults.suite)

    // Location of snackbar on screen
    static let snackbarLocation = Key<SnackbarLocation>("snackbarLocation", default: .topCenter, suite: Defaults.suite)

    // Blocklist
    static let blocklist = Key<[String]>("blocklist", default: [], suite: Defaults.suite)
    static let isBlocklistInverted = Key<Bool>("isBlocklistInverted", default: false, suite: Defaults.suite)

    // Array of general preference keys
    static let allGeneralKeys: [Defaults.Keys] = [.defaultRate, .minimumRate, .maximumRate, .snackbarLocation]

}
