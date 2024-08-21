//
//  ShortcutViewController.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 6/19/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import MASShortcut

class ShortcutViewController: NSViewController {

    var shortcutIndex: Int?
    var shortcut: Shortcut?

    var action: Shortcut.Action = .speedUp() {
        didSet {
            switch action {
            case let .slowDown(amount), let .speedUp(amount):
                valueLabel.stringValue = "Speed interval:"

                valueTextField.formatter = Shortcut.Action.rateFormatter
                valueTextField.doubleValue = amount

                valueDescriptionLabel.stringValue = "Enter a decimal value"

                gridView.row(at: GridRow.value).isHidden = false
                gridView.row(at: GridRow.valueDescription).isHidden = false

            case let .setRate(rate):
                valueLabel.stringValue = "Speed value:"

                valueTextField.formatter = Shortcut.Action.rateFormatter
                if let rate {
                    valueTextField.doubleValue = rate
                } else {
                    valueTextField.stringValue = ""
                }

                valueDescriptionLabel.stringValue = "Leave empty for default speed"

                gridView.row(at: GridRow.value).isHidden = false
                gridView.row(at: GridRow.valueDescription).isHidden = false

            case let .skipBackward(seconds), let .skipForward(seconds):
                valueLabel.stringValue = "Skip interval:"

                valueTextField.formatter = Shortcut.Action.timeFormatter
                valueTextField.integerValue = seconds

                valueDescriptionLabel.stringValue = "Enter an integer in seconds"

                gridView.row(at: GridRow.value).isHidden = false
                gridView.row(at: GridRow.valueDescription).isHidden = false

            default:
                valueTextField.resignFirstResponder()
                gridView.row(at: GridRow.value).isHidden = true
                gridView.row(at: GridRow.valueDescription).isHidden = true
            }
        }
    }

    // MARK: - Views

    var gridView: NSGridView!

    var actionLabel: NSTextField!
    var actionButton: NSPopUpButton!

    var shortcutLabel: NSTextField!
    var shortcutDescriptionLabel: NSTextField!
    var shortcutView: MASShortcutView!

    var valueLabel: NSTextField!
    var valueDescriptionLabel: NSTextField!
    var valueTextField: NSTextField!

    var checkboxStackView: NSStackView!
    var showSnackbarCheckbox: NSButton!
    var showInContextMenuCheckbox: NSButton!
    var isGlobalCheckbox: NSButton!

    var buttonStackView: NSStackView!
    var deleteButton: NSButton!
    var cancelButton: NSButton!
    var saveButton: NSButton!

    enum GridRow {
        static let action = 0
        static let shortcut = 1
        static let shortcutDescription = 2
        static let value = 3
        static let valueDescription = 4
        static let checkbox = 5
    }

    override func loadView() {
        super.loadView()

        // We're not using auto-layout, so need to set a preferred content size for Preferences window to show
        preferredContentSize = .zero

        (actionLabel, actionButton) = createLabeledPopupButton(title: "Shortcut action", action: #selector(updateAction(_:)))
        actionButton.addItems(withTitles: Shortcut.Action.allCases.map(\.defaultDescription))

        shortcutLabel = createLabel(title: "Key combination")
        shortcutDescriptionLabel = createDescriptionLabel(withText: "Enter single key or with modifier keys")

        shortcutView = MASShortcutView()
        shortcutView.style = .default
        shortcutView.shortcutValidator = ShortcutValidator()
        shortcutView.shortcutValueChange = { _ in self.updateViews() }

        valueLabel = NSTextField(labelWithString: "")
        valueDescriptionLabel = createDescriptionLabel(withText: "")

        valueTextField = NSTextField()
        valueTextField.refusesFirstResponder = true
        valueTextField.delegate = self

        showSnackbarCheckbox = NSButton(checkboxWithTitle: "Show notification", target: nil, action: nil)
        showInContextMenuCheckbox = NSButton(checkboxWithTitle: "Show in right-click menu", target: nil, action: nil)
        isGlobalCheckbox = NSButton(checkboxWithTitle: "Enable global shortcut", target: nil, action: nil)
        isGlobalCheckbox.toolTip = "Shortcuts with modifier keys can be triggered outside of Safari."

        checkboxStackView = NSStackView(views: [showSnackbarCheckbox, showInContextMenuCheckbox, isGlobalCheckbox])
        checkboxStackView.orientation = .vertical
        checkboxStackView.alignment = .leading
        checkboxStackView.setContentHuggingPriority(.required, for: .vertical)

        deleteButton = NSButton(title: "Delete", target: self, action: #selector(delete))
        deleteButton.isHidden = shortcut == nil

        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        saveButton = NSButton(title: "Save", target: self, action: #selector(save(_:)))

        buttonStackView = NSStackView(views: [cancelButton, saveButton])
        buttonStackView.orientation = .horizontal

        gridView = NSGridView(views: [
            [actionLabel, actionButton],
            [shortcutLabel, shortcutView],
            [NSGridCell.emptyContentView, shortcutDescriptionLabel],
            [valueLabel, valueTextField],
            [NSGridCell.emptyContentView, valueDescriptionLabel],
            [NSGridCell.emptyContentView, checkboxStackView],
        ])

        gridView.columnSpacing = 8
        gridView.column(at: 0).xPlacement = .trailing

        gridView.row(at: GridRow.action).bottomPadding = 8
        gridView.row(at: GridRow.value).topPadding = 8
        gridView.row(at: GridRow.value).isHidden = true
        gridView.row(at: GridRow.valueDescription).isHidden = true
        gridView.row(at: GridRow.checkbox).topPadding = 8

        gridView.cell(atColumnIndex: 1, rowIndex: GridRow.shortcut).yPlacement = .center  // shortcut view
        gridView.cell(atColumnIndex: 0, rowIndex: GridRow.value).yPlacement = .center  // value label
        gridView.cell(atColumnIndex: 1, rowIndex: GridRow.checkbox).yPlacement = .top  // checkbox

        view.addSubview(gridView)
        view.addSubview(deleteButton)
        view.addSubview(buttonStackView)

        addVisualConstraints([
            "V:[shortcutView(19)]",
            "H:[valueTextField(64)]",
            "V:[valueTextField(22)]",
            "H:|-[gridView]-|",
            "V:|-[gridView]-(>=16)-[buttonStackView]-|",
            "H:[buttonStackView]-|",
            "V:[deleteButton]-|",
            "H:|-[deleteButton]",
        ])

        gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if let shortcut {
            // Set values based on existing shortcut
            action = shortcut.action
            actionButton.selectItem(at: shortcut.action.index)
            shortcutView.shortcutValue = MASShortcut(keyCode: shortcut.keyCode, modifierFlags: shortcut.modifiers)
            isGlobalCheckbox.state = shortcut.isGlobal ? .on : .off
            showSnackbarCheckbox.state = shortcut.showSnackbar ? .on : .off
            showInContextMenuCheckbox.state = shortcut.showInContextMenu ? .on : .off
        } else {
            // Set default values for a new shortcut
            action = .speedUp()
            isGlobalCheckbox.isEnabled = false
            showSnackbarCheckbox.state = .on
        }

        updateViews()
    }

    private func updateViews() {
        let shortcutValue: MASShortcut! = shortcutView.shortcutValue

        isGlobalCheckbox.isEnabled =
            shortcutValue != nil
            ? !shortcutValue.modifierFlags.isDisjoint(with: [.command, .control, .option])
            : false

        // Shortcut must be recorded to allow saving
        saveButton.isEnabled = shortcutValue != nil

        // Require valid value input to allow saving
        if !valueTextField.isHidden {
            // If the control is in the process of editing the affected cell, then it invokes the validateEditing()
            // method before getting the value, which causes issues when trying to input certain numbers (e.g., 3.0)
            // https://stackoverflow.com/questions/6337464/nsnumberformatter-doesnt-allow-typing-decimal-numbers
            if let last = valueTextField.currentEditor()?.string.last,
                let formatter = valueTextField.formatter as? NumberFormatter,
                formatter.allowsFloats,
                String(last) == formatter.decimalSeparator
            {
                // Disable saving while number input is incomplete
                saveButton.isEnabled = false
            } else {
                switch action {
                case .setRate:
                    // Default rate allows for empty text field...
                    saveButton.isEnabled = saveButton.isEnabled && (!valueTextField.objectValue.isNil || valueTextField.stringValue.isEmpty)
                default:
                    // ...any others require a valid, non-empty value
                    saveButton.isEnabled = saveButton.isEnabled && !valueTextField.objectValue.isNil
                }
            }
        }

        // Show rate will always show snackbar
        // Disable snackbar for fullscreen since animation is laggy
        showSnackbarCheckbox.isHidden = [.showRate, .fullscreen].contains(action)
    }

    @objc private func updateAction(_ sender: NSPopUpButton) {
        action = Shortcut.Action.allCases[sender.indexOfSelectedItem]
        updateViews()
    }

    @objc private func delete(_: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to delete this shortcut?"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Delete Shortcut")
        alert.addButton(withTitle: "Cancel")

        if case .alertFirstButtonReturn = alert.runModal() {
            if let shortcutIndex {
                Defaults[.shortcuts].remove(at: shortcutIndex)
            }
            dismiss(self)
        }
    }

    @objc private func cancel(_: NSButton) {
        // Don't save create a new shortcut/save any changes
        dismiss(self)
    }

    @objc private func save(_: NSButton) {
        // Update associated value for action
        switch action {
        case .slowDown, .speedUp:
            action.set(associatedValue: valueTextField.doubleValue)
        case .setRate:
            action.set(associatedValue: !valueTextField.stringValue.isEmpty ? valueTextField.doubleValue : nil)
        case .skipBackward, .skipForward:
            action.set(associatedValue: valueTextField.integerValue)
        default:
            break
        }

        let newShortcut = Shortcut(
            action: action,
            keyCode: shortcutView.shortcutValue?.keyCode ?? 0,
            modifiers: shortcutView.shortcutValue?.modifierFlags ?? [],
            isEnabled: shortcut?.isEnabled ?? true,
            isGlobal: isGlobalCheckbox.isEnabled && isGlobalCheckbox.state == .on,
            showSnackbar: showSnackbarCheckbox.state == .on,
            showInContextMenu: showInContextMenuCheckbox.state == .on,
            identifier: shortcut?.identifier ?? UUID().uuidString
        )

        if let shortcutIndex {
            Defaults[.shortcuts][shortcutIndex] = newShortcut
        } else {
            Defaults[.shortcuts].append(newShortcut)
        }

        if let shortcutsViewController = presentingViewController as? ShortcutsViewController {
            shortcutsViewController.registerUndoInsert(newShortcut, at: Defaults[.shortcuts].endIndex - 1, new: true)
        }

        dismiss(self)
    }
}

extension ShortcutViewController: NSTextFieldDelegate {
    func controlTextDidChange(_: Notification) {
        updateViews()
    }
}

class ShortcutValidator: MASShortcutValidator {
    override init() {
        super.init()
        allowAnyShortcutWithOptionModifier = true
    }

    // Allow shortcuts without modifier keys, etc.
    override func isShortcutValid(_: MASShortcut!) -> Bool { true }

    override func isShortcut(_: MASShortcut!, alreadyTakenIn _: NSMenu!, explanation _: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        false
    }
}
