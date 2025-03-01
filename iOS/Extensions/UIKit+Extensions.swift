//
//  Extensions.swift
//  Extensions
//
//  Created by Ritam Sarmah on 9/9/21.
//

import UIKit

extension UIKeyModifierFlags: @retroactive Decodable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: decoder.singleValueContainer().decode(Int.self))
    }
}

extension NumberFormatter {
    func string(from number: NSNumber?, defaultValue: String = "") -> String {
        guard let number = number else { return defaultValue }
        return string(from: number) ?? defaultValue
    }

    func string(from int: Int?, defaultValue: String = "") -> String {
        guard let int = int else { return defaultValue }
        return string(from: NSNumber(value: int), defaultValue: defaultValue)
    }

    func string(from double: Double?, defaultValue: String = "") -> String {
        guard let double = double else { return defaultValue }
        return string(from: NSNumber(value: double), defaultValue: defaultValue)
    }
}
