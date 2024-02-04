//
//  Extensions.swift
//  Extensions
//
//  Created by Ritam Sarmah on 9/9/21.
//

import UIKit

extension Array {
    mutating func remove(at indices: [Int]) {
        Set(indices)
            .sorted(by: >)
            .forEach { self.remove(at: $0) }
    }
}

extension RandomAccessCollection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /// - complexity: O(1)
    public subscript(safe index: Index) -> Element? {
        guard index >= startIndex, index < endIndex else {
            return nil
        }
        return self[index]
    }

}

extension UIKeyModifierFlags: Decodable {
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
