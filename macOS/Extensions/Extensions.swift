//
//  Extensions.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/3/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Carbon
import Defaults
import Foundation
import SafariServices

extension SFSafariPage {
    func triggerAction(for shortcut: Shortcut) {
        dispatchMessageToScript(withName: "triggerAction", userInfo: ["shortcut": shortcut.dictionaryRepresentation])
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

extension NSEvent.ModifierFlags: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: decoder.singleValueContainer().decode(UInt.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension NSEvent.ModifierFlags: CustomStringConvertible {
    public var description: String {
        var scalars = [UnicodeScalar]()

        // Using standard macOS-based ordering
        if contains(.control) { scalars.append(UnicodeScalar(kControlUnicode)!) }
        if contains(.option) { scalars.append(UnicodeScalar(kOptionUnicode)!) }
        if contains(.shift) { scalars.append(UnicodeScalar(kShiftUnicode)!) }
        if contains(.command) { scalars.append(UnicodeScalar(kCommandUnicode)!) }

        return scalars.map { String($0) }.joined()
    }
}

extension NSViewController {
    func constructViewBindings() -> [String: NSView] {
        var bindings = [String: NSView]()
        let mirror = Mirror(reflecting: self)

        _ = mirror.children.compactMap {
            guard let name = $0.label, let view = $0.value as? NSView else { return }
            bindings[name] = view
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        bindings.forEach { $0.value.translatesAutoresizingMaskIntoConstraints = false }

        return bindings
    }
}

extension [Shortcut] {
    var toolbarShortcutIndex: Int? {
        guard let toolbarShortcutIdentifier = Defaults[.toolbarShortcutIdentifier] else { return nil }
        return Defaults[.shortcuts].firstIndex(where: { $0.identifier == toolbarShortcutIdentifier })
    }
}

extension NSAlert {
    static func showAlert(title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title

            if let message {
                alert.informativeText = message
            }

            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    static func showAlert(error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert(error: error)
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

extension NSImage {
    func tinted(if condition: Bool) -> NSImage {
        let color: NSColor =
            if #available(macOS 10.14, *) {
                condition ? .controlAccentColor : .gray
            } else {
                condition ? .systemBlue : .gray
            }

        guard let tinted = copy() as? NSImage else { return self }
        tinted.lockFocus()
        color.set()

        let imageRect = NSRect(origin: .zero, size: size)
        imageRect.fill(using: .sourceAtop)

        tinted.unlockFocus()
        tinted.isTemplate = false
        return tinted
    }
}

// Symbol images only work on 11.0+, use PNGs otherwise (13pt size)
extension NSImage.Name {
    static let bell: NSImage.Name =
        if #available(macOS 11.0, *) {
            .init("bell-symbol")
        } else {
            .init("bell")
        }

    static let contextualMenu: NSImage.Name =
        if #available(macOS 11.0, *) {
            .init("contextualmenu-symbol")
        } else {
            .init("contextualmenu")
        }

    static let globe: NSImage.Name =
        if #available(macOS 11.0, *) {
            .init("globe-symbol")
        } else {
            .init("globe")
        }
}

extension NSButton {
    static func untitledCheckbox(target: Any? = nil, action: Selector? = nil) -> NSButton {
        let checkbox = NSButton(checkboxWithTitle: "", target: target, action: action)
        checkbox.title = ""  // We need to explicitly set the checkbox title to empty string for macOS 10.13
        return checkbox
    }

    static func helpButton(target: Any? = nil, action: Selector? = nil) -> NSButton {
        let helpButton = NSButton(title: "", target: target, action: action)
        helpButton.title = ""  // We need to explicitly set the button title to empty string for macOS 10.13
        helpButton.bezelStyle = .helpButton
        helpButton.setAccessibilityLabel("Help")
        return helpButton
    }

    func setCheckboxState(with value: Bool) {
        self.state = value ? .on : .off
    }
}

// Custom nil coalescing operator for providing a default String value to any optional type
infix operator ??? : NilCoalescingPrecedence

public func ??? (optional: (some Any)?, defaultValue: @autoclosure () -> String) -> String {
    optional.map { String(describing: $0) } ?? defaultValue()
}

extension NSTableView {
    func dequeueReusableView<T>(withIdentifier identifier: NSUserInterfaceItemIdentifier, for row: Int, creationBlock: () -> T) -> T {
        if let cell = makeView(withIdentifier: identifier, owner: self) as? T {
            return cell
        }

        return creationBlock()
    }
}
