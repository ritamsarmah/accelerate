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

    static let shared = Logger(subsystem: subsystem, category: category)
}
