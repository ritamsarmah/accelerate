//
//  SafariWebExtensionHandler.swift
//  Accelerate Extension
//
//  Created by Ritam Sarmah on 8/22/21.
//

import Defaults
import Foundation
import SafariServices

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    private var settings: [String: Any] {
        let shortcuts = Defaults[.shortcuts]
            .filter { $0.isEnabled }
            .map(\.dictionaryRepresentation)

        return [
            "shortcuts": shortcuts,
            "defaultRate": Defaults[.defaultRate],
            "minimumRate": Defaults[.minimumRate],
            "maximumRate": Defaults[.maximumRate],
            "snackbarLocation": Defaults[.snackbarLocation].description,
            "blocklist": Defaults[.blocklist],
            "isBlocklistInverted": Defaults[.isBlocklistInverted],
            "isVerboseLogging": _isDebugAssertConfiguration() || Defaults[.isVerboseLogging],
        ]
    }

    // https://developer.apple.com/documentation/safariservices/safari_web_extensions/messaging_between_the_app_and_javascript_in_a_safari_web_extension
    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey] as! [String: Any]
        let messageName = message["name"] as! String
        let response = NSExtensionItem()

        switch messageName {
        case "initialize":
            response.userInfo = [SFExtensionMessageKey: ["settings": settings]]
        default:
            Log.shared.warning("Received unrecognized message from script: \(message.debugDescription)")
            return
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
