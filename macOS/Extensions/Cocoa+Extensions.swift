//
//  Cocoa+Extensions.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/3/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Carbon
import Cocoa
import Defaults

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

    // MARK: UI Helpers

    func createLabeledPopupButton(title: String, action: Selector) -> (NSTextField, NSPopUpButton) {
        let label = createLabel(title: title)

        let button = NSPopUpButton()
        button.target = self
        button.action = action
        button.setAccessibilityLabel(title)

        return (label, button)
    }

    func createLabeledTextField(title: String, action: Selector) -> (NSTextField, NSTextField) {
        let label = createLabel(title: title)

        let textField = NSTextField()
        textField.formatter = Shortcut.Action.rateFormatter
        textField.refusesFirstResponder = true
        textField.target = self
        textField.action = action
        textField.setAccessibilityLabel(title)

        return (label, textField)
    }

    func createLabel(title: String) -> NSTextField {
        let label = NSTextField(labelWithString: "\(title):")
        label.alignment = .right
        return label
    }

    func createDescriptionLabel(withText text: String) -> NSTextField {
        let descriptionLabel = NSTextField(labelWithString: text)
        descriptionLabel.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        return descriptionLabel
    }

    func createButton(title: String, action: Selector, accessibilityLabel: String) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.setAccessibilityLabel(accessibilityLabel)
        return button
    }

    func addVisualConstraints(_ constraints: [String]) {
        let bindings = constructViewBindings()
        constraints
            .map { NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: bindings) }
            .forEach { view.addConstraints($0) }
    }

    private func constructViewBindings() -> [String: NSView] {
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

extension NSTableView {
    func dequeueReusableView<T>(withIdentifier identifier: NSUserInterfaceItemIdentifier, for row: Int, creationBlock: () -> T) -> T {
        if let cell = makeView(withIdentifier: identifier, owner: self) as? T {
            return cell
        }

        return creationBlock()
    }
}
