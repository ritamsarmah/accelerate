//
//  ShortcutsViewController.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/17/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import Preferences

class ShortcutsViewController: NSViewController, PreferencePane {

    // MARK: - PreferencePane

    let preferencePaneIdentifier = Preferences.PaneIdentifier.shortcuts
    let preferencePaneTitle = "Shortcuts"
    let toolbarItemIcon: NSImage =
        if #available(macOS 11.0, *) {
            .init(systemSymbolName: "keyboard", accessibilityDescription: "Shortcuts")!
        } else {
            .init(named: NSImage.preferencesGeneralName)!  // unused
        }

    override var nibName: NSNib.Name? { "ShortcutsViewController" }

    // MARK: - Views

    private var gridView: NSGridView!

    private var toolbarShortcutLabel: NSTextField!
    private var toolbarShortcutButton: NSPopUpButton!
    private var toolbarShortcutDescriptionLabel: NSTextField!

    private var shortcutTableViewDescriptionLabel: NSTextField!
    private var shortcutTableView: EditableTableView!

    private var restoreButton: NSButton!

    private var shortcutsObserver: DefaultsObservation?

    private enum Identifier {
        static let isEnabledColumn = NSUserInterfaceItemIdentifier(rawValue: "IsEnabledColumn")
        static let actionColumn = NSUserInterfaceItemIdentifier(rawValue: "ActionColumn")
        static let keyComboColumn = NSUserInterfaceItemIdentifier(rawValue: "KeyComboColumn")
        static let optionsColumn = NSUserInterfaceItemIdentifier(rawValue: "OptionsColumn")

        static let cell = NSUserInterfaceItemIdentifier(rawValue: "ShortcutCell")
    }

    override func loadView() {
        super.loadView()

        // We're not using auto-layout, so need to set a preferred content size for Preferences window to show
        preferredContentSize = .zero

        (toolbarShortcutLabel, toolbarShortcutButton) = createLabeledPopupButton(title: "Toolbar button action", action: #selector(updateToolbarShortcutIdentifier(_:)))
        toolbarShortcutDescriptionLabel = createDescriptionLabel(withText: "This action is triggered by clicking the button\n for Accelerate in the Safari toolbar.")
        shortcutTableViewDescriptionLabel = createDescriptionLabel(withText: "Click Add (+) to create a shortcut. To edit shortcut options, double-click it.")
        shortcutTableView = createShortcutTableView()
        restoreButton = createButton(title: "Restore Defaults", action: #selector(restoreDefaults(_:)), accessibilityLabel: "Restore defaults")

        gridView = NSGridView(views: [
            [toolbarShortcutLabel, toolbarShortcutButton],
            [NSGridCell.emptyContentView, toolbarShortcutDescriptionLabel],
            [shortcutTableViewDescriptionLabel, NSGridCell.emptyContentView],
            [shortcutTableView, NSGridCell.emptyContentView],
        ])

        gridView.columnSpacing = 8
        gridView.column(at: 0).xPlacement = .trailing
        gridView.row(at: 1).bottomPadding = 16
        gridView.mergeCells(inHorizontalRange: NSRange(0..<2), verticalRange: NSRange(2..<3))
        gridView.mergeCells(inHorizontalRange: NSRange(0..<2), verticalRange: NSRange(3..<4))

        view.addSubview(gridView)
        view.addSubview(restoreButton)

        let bindings = constructViewBindings()

        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=32)-[gridView]-(>=32)-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[shortcutTableView(256)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[gridView]-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[restoreButton]-(>=32)-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[restoreButton]-|", options: [], metrics: nil, views: bindings),
        ]

        constraints.forEach { view.addConstraints($0) }

        gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Add observer for changes to shortcuts
        // NOTE: Registering this observer will immediately call it
        shortcutsObserver = Defaults.observe(.shortcuts) { _ in self.updateViews() }
    }

    private func createShortcutTableView() -> EditableTableView {
        let shortcutTableView = EditableTableView()
        shortcutTableView.maximumNumberOfRows = Shortcut.maximumShortcuts
        shortcutTableView.tableView.dataSource = self
        shortcutTableView.tableView.delegate = self
        shortcutTableView.tableView.usesAlternatingRowBackgroundColors = true
        shortcutTableView.tableView.register(nil, forIdentifier: Identifier.cell)
        shortcutTableView.tableView.registerForDraggedTypes([.string])
        shortcutTableView.setAccessibilityLabel("Shortcuts")

        // Columns

        let isEnabledTableViewColumn = NSTableColumn(identifier: Identifier.isEnabledColumn)
        isEnabledTableViewColumn.title = ""
        isEnabledTableViewColumn.headerToolTip = "Select to enable shortcut"
        isEnabledTableViewColumn.width = NSButton.untitledCheckbox().frame.width + 24
        shortcutTableView.tableView.addTableColumn(isEnabledTableViewColumn)

        let actionTableViewColumn = NSTableColumn(identifier: Identifier.actionColumn)
        actionTableViewColumn.title = "Action"
        actionTableViewColumn.headerToolTip = "The action triggered by the shortcut"
        actionTableViewColumn.width = 170
        shortcutTableView.tableView.addTableColumn(actionTableViewColumn)

        let keyComboTableViewColumn = NSTableColumn(identifier: Identifier.keyComboColumn)
        keyComboTableViewColumn.title = "Shortcut"
        keyComboTableViewColumn.headerToolTip = "The key combination that triggers the action"
        keyComboTableViewColumn.width = 60
        shortcutTableView.tableView.addTableColumn(keyComboTableViewColumn)

        let optionsTableViewColumn = NSTableColumn(identifier: Identifier.optionsColumn)
        optionsTableViewColumn.title = "Options"
        optionsTableViewColumn.headerToolTip = "Additional options for each shortcut"
        optionsTableViewColumn.width = 60
        shortcutTableView.tableView.addTableColumn(optionsTableViewColumn)

        // Actions

        shortcutTableView.addAction = { [unowned self] _ in
            presentAsSheet(ShortcutViewController())
        }

        shortcutTableView.removeAction = { [unowned self] _, index in
            guard let index else { return }

            let shortcut = Defaults[.shortcuts].remove(at: index)

            // Check if toolbar shortcut was set to the removed shortcut
            if shortcut.identifier == Defaults[.toolbarShortcutIdentifier] {
                Defaults[.toolbarShortcutIdentifier] = nil
            }

            registerUndoRemove(shortcut, at: index)
        }

        shortcutTableView.editAction = { [unowned self] _, selectedRow in
            let viewController = ShortcutViewController()
            viewController.shortcutIndex = selectedRow
            viewController.shortcut = Defaults[.shortcuts][selectedRow]
            presentAsSheet(viewController)
        }

        return shortcutTableView
    }

    private func updateViews() {
        DispatchQueue.main.async {
            self.shortcutTableView.reload()

            // NOTE: Don't use NSPopUpButton.addItems(withTitles:) since it will remove duplicate titles
            // Also don't use the `items` property since it is not available prior to macOS 10.14
            let items =
                [NSMenuItem(title: "None", action: nil, keyEquivalent: "")]
                + Defaults[.shortcuts].map { NSMenuItem(title: $0.action.description, action: nil, keyEquivalent: "") }

            self.toolbarShortcutButton.menu?.removeAllItems()
            items.forEach { self.toolbarShortcutButton.menu?.addItem($0) }

            self.toolbarShortcutButton.selectItem(at: (Defaults[.shortcuts].toolbarShortcutIndex ?? -1) + 1)
        }
    }

    @objc private func updateToolbarShortcutIdentifier(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            Defaults[.toolbarShortcutIdentifier] = nil
        } else {
            Defaults[.toolbarShortcutIdentifier] = Defaults[.shortcuts][sender.indexOfSelectedItem - 1].identifier
        }
    }

    @objc private func restoreDefaults(_: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to restore the default shortcuts?"
        alert.informativeText = "Any custom shortcuts will be permanently overwritten."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            Defaults.reset(Defaults.Keys.allShortcutKeys)
            undoManager?.removeAllActions()
            updateViews()
        default:
            break
        }
    }

    // MARK: - Undo Manager

    func registerUndoRemove(_ shortcut: Shortcut, at index: Int) {
        undoManager?.registerUndo(
            withTarget: self,
            handler: { target in
                target.registerUndoInsert(shortcut, at: index, new: false)
                Defaults[.shortcuts].insert(shortcut, at: index)
            }
        )
        undoManager?.setActionName("Delete of \"\(shortcut.action.description)\"")
    }

    func registerUndoInsert(_ shortcut: Shortcut, at index: Int, new isNew: Bool) {
        // Scroll to show added item
        DispatchQueue.main.async {
            self.shortcutTableView.tableView.scrollRowToVisible(index)
        }

        undoManager?.registerUndo(
            withTarget: self,
            handler: { target in
                target.registerUndoRemove(Defaults[.shortcuts].remove(at: index), at: index)
            }
        )

        if isNew {
            undoManager?.setActionName("New Shortcut \"\(shortcut.action.description)\"")
        } else {
            undoManager?.setActionName("Delete of \"\(shortcut.action.description)\"")
        }
    }
}

// MARK: - Table View

extension ShortcutsViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in _: NSTableView) -> Int { Defaults[.shortcuts].count }

    func tableView(_: NSTableView, didAdd rowView: NSTableRowView, forRow _: Int) {
        rowView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: rowView.centerYAnchor, constant: -1).isActive = true
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else { return nil }

        let shortcut = Defaults[.shortcuts][row]
        let identifier = column.identifier

        switch identifier {
        case Identifier.isEnabledColumn:
            let button: NSButton = tableView.dequeueReusableView(withIdentifier: identifier, for: row) {
                // Hack to show from the top when appearing (otherwise it scrolls to bottom by default)
                if row == 0 { tableView.scrollRowToVisible(0) }

                return NSButton.untitledCheckbox(target: self, action: #selector(toggleShortcutEnabled(_:)))
            }

            button.setCheckboxState(with: shortcut.isEnabled)
            button.tag = row
            return button

        case Identifier.actionColumn, Identifier.keyComboColumn:
            let stringValue = identifier == Identifier.actionColumn ? shortcut.action.description : shortcut.keyComboString
            let textField: NSTextField = tableView.dequeueReusableView(withIdentifier: identifier, for: row) {
                NSTextField(labelWithString: stringValue)
            }

            textField.stringValue = stringValue
            textField.usesSingleLineMode = false
            return textField

        case Identifier.optionsColumn:
            let images = [
                NSImage(named: .bell)!.tinted(if: shortcut.showSnackbar),
                NSImage(named: .contextualMenu)!.tinted(if: shortcut.showInContextMenu),
                NSImage(named: .globe)!.tinted(if: shortcut.isGlobal),
            ]

            let stackView = tableView.dequeueReusableView(withIdentifier: Identifier.optionsColumn, for: row) {
                let imageViews = images.map { NSImageView(image: $0) }
                let stackView = NSStackView(views: imageViews)
                stackView.orientation = .horizontal
                stackView.spacing = 8
                return stackView
            }

            let imageViews = stackView.views.map { $0 as! NSImageView }
            zip(imageViews, images).forEach { $0.image = $1 }

            return stackView

        default:
            return nil
        }
    }

    func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        "\(row)" as NSString
    }

    func tableView(_: NSTableView, validateDrop _: NSDraggingInfo, proposedRow _: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        dropOperation == .above ? .move : []
    }

    func tableView(_: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation _: NSTableView.DropOperation) -> Bool {
        guard let item = info.draggingPasteboard.pasteboardItems?.first,
            let rowString = item.string(forType: .string),
            let oldRow = Int(rowString)
        else { return false }

        // When you drag an item downwards, the "new row" index is actually --1. Remember dragging operation is `.above`.
        let newRow = oldRow < row ? row - 1 : row
        let shortcut = Defaults[.shortcuts].remove(at: oldRow)
        Defaults[.shortcuts].insert(shortcut, at: newRow)

        return true
    }

    @objc private func toggleShortcutEnabled(_ sender: NSButton) {
        Defaults[.shortcuts][sender.tag].isEnabled = sender.state == .on
    }
}
