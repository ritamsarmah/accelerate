//
//  Swift+Extensions.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//

import Defaults
import Foundation

// Custom nil coalescing operator for providing a default String value to any optional type
infix operator ??? : NilCoalescingPrecedence

public func ??? (optional: (some Any)?, defaultValue: @autoclosure () -> String) -> String {
    optional.map { String(describing: $0) } ?? defaultValue()
}

extension String {
    func replacingFirstOccurrence(
        of target: some StringProtocol, with replacement: some StringProtocol, options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
    ) -> String {
        if let range = range(of: target, options: options, range: searchRange) {
            replacingCharacters(in: range, with: replacement)
        } else {
            self
        }
    }
}

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
