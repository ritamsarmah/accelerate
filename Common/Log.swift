//
//  Log.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//

import Foundation
import os.log

class Log {
    private static let category = "Accelerate"
    private static let subsystem: String = Bundle.main.bundleIdentifier!

    #if os(iOS)
        static let shared = Logger(subsystem: subsystem, category: category)
    #elseif os(macOS)
        private static let log = OSLog(subsystem: subsystem, category: category)

        static func error(_ message: StaticString, _ args: CVarArg...) {
            os_log(message, log: log, type: .error, args)
        }

        static func warn(_ message: StaticString, _ args: CVarArg...) {
            os_log(message, log: log, type: .default, args)
        }

        static func debug(_ message: StaticString, _ args: CVarArg...) {
            os_log(message, log: log, type: .debug, args)
        }

        static func info(_ message: StaticString, _ args: CVarArg...) {
            os_log(message, log: log, type: .info, args)
        }
    #endif
}
