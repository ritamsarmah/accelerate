//
//  Safari+Extensions.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/10/24.
//  Copyright © 2024 Ritam Sarmah. All rights reserved.
//

import Defaults
import SafariServices

extension SFSafariPage {
    func triggerAction(for shortcut: Shortcut) {
        dispatchMessageToScript(withName: "triggerAction", userInfo: ["shortcut": shortcut.dictionaryRepresentation])
    }
    
    func triggerContextMenuAction(for command: String) {
        dispatchMessageToScript(withName: "triggerContextMenuAction", userInfo: ["index": Int(command)!])
    }

    func isAllowed(completion: @escaping (_ isAllowed: Bool, _ rule: String?) -> Void) {
        getPropertiesWithCompletionHandler { properties in
            guard let url = properties?.url else {
                completion(false, nil)
                return
            }

            let blocklistRule = self.findRule(for: url, in: Defaults[.blocklist])
            let isBlocklistInverted = Defaults[.isBlocklistInverted]
            let isPageAllowed = blocklistRule != nil ? isBlocklistInverted : !isBlocklistInverted

            completion(isPageAllowed, blocklistRule)
        }
    }

    private func findRule(for url: URL, in rules: [String]) -> String? {
        let prefix = "^(https?://)?(www\\.)?"
        let urlString = url.absoluteString.replacingFirstOccurrence(of: prefix, with: "", options: .regularExpression)

        return
            rules
            .filter { !$0.isEmpty }
            .first { rule in
                let predicateRule =
                    rule
                    .replacingOccurrences(of: "?", with: "\\?")  // Escape question marks in URL
                    .replacingFirstOccurrence(of: prefix, with: "", options: .regularExpression)

                // [c] means case insensitive
                let predicate = NSPredicate(format: "SELF LIKE[c] %@", "\(predicateRule)*")

                // Return whether URL matches a rule
                return predicate.evaluate(with: urlString)
            }
    }
}
