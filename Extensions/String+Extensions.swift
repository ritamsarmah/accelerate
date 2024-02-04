//
//  String+Extensions.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//

import Foundation

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
