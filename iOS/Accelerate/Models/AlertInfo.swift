//
//  AlertInfo.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 11/11/21.
//

import Defaults
import SwiftUI
import UIKit

struct AlertInfo {

    enum ButtonType {
        case `default`, cancel, destructive
    }

    var title: String
    var message: String?
    var shouldDismissView: Bool = false

    var primaryButtonText: String
    var primaryButtonType: ButtonType = .default
    var primaryButtonAction: (() -> Void)?

    var secondaryButtonText: String?
    var secondaryButtonType: ButtonType = .default
    var secondaryButtonAction: (() -> Void)?

    var primaryButton: Alert.Button {
        switch primaryButtonType {
        case .default:
            .default(Text(primaryButtonText), action: { secondaryButtonAction?() })
        case .cancel:
            .cancel(Text(primaryButtonText), action: { secondaryButtonAction?() })
        case .destructive:
            .destructive(Text(primaryButtonText), action: { secondaryButtonAction?() })
        }
    }

    var secondaryButton: Alert.Button? {
        guard let secondaryButtonText else { return nil }

        switch secondaryButtonType {
        case .default:
            return .default(Text(secondaryButtonText), action: { secondaryButtonAction?() })
        case .cancel:
            return .cancel(Text(secondaryButtonText), action: { secondaryButtonAction?() })
        case .destructive:
            return .destructive(Text(secondaryButtonText), action: { secondaryButtonAction?() })
        }
    }

    // Static UIAlertController Functions

    enum AlertType {
        case blocklistAddRule, blocklistHelp
        case tipLoadFailed(error: Error)
        case tipPurchaseFailed(error: Error)

        var alert: UIAlertController {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

            switch self {
            case .blocklistAddRule:
                alert.title = "Add Website Rule"
                alert.message = "Enter a website domain to ignore all URLs starting with that domain."

                alert.addTextField { textField in
                    textField.placeholder = "example.com"
                }

                alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(
                    .init(
                        title: "Add", style: .default,
                        handler: { _ in
                            if let rule = alert.textFields?.first?.text {
                                Defaults[.blocklist].append(rule)
                            }
                        }
                    ))
            case .blocklistHelp:
                alert.title = "How to Use Blocklist"
                alert.message = "Blocked websites are ignored by default. A rule like \"example.com\" disables Accelerate on all URLs starting with that domain.\n\nThe asterisk wildcard can represent zero or more of any character, e.g., *.example.com matches \"my.example.com\"."
                alert.addAction(.init(title: "Done", style: .cancel))

            case let .tipLoadFailed(error):
                alert.title = "Error connecting to App Store"
                alert.message = error.localizedDescription
                alert.addAction(.init(title: "OK", style: .cancel))

            case let .tipPurchaseFailed(error):
                alert.title = "Tip purchase failed"
                alert.message = error.localizedDescription
                alert.addAction(.init(title: "OK", style: .cancel))
            }

            return alert
        }
    }

    static func showAlert(_ alertType: AlertType) {
        topViewControllerInKeyWindow()?.present(alertType.alert, animated: true)
    }

    private static func topViewControllerInKeyWindow() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard var topViewController = keyWindow?.rootViewController else { return nil }

        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }
}

// Add initializer for SwiftUI alert using AlertInfo
extension Alert {
    init(alertInfo: AlertInfo) {
        let messageText = alertInfo.message != nil ? Text(alertInfo.message!) : nil

        if let secondaryButton = alertInfo.secondaryButton {
            self.init(
                title: Text(alertInfo.title),
                message: messageText,
                primaryButton: alertInfo.primaryButton,
                secondaryButton: secondaryButton
            )
        } else {
            self.init(title: Text(alertInfo.title), message: messageText, dismissButton: alertInfo.primaryButton)
        }
    }
}
