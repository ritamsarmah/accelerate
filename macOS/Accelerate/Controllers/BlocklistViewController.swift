//
//  BlocklistViewController.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/17/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import Preferences

class BlocklistViewController: NSViewController, PreferencePane {

    // MARK: - PreferencePane

    let preferencePaneIdentifier = Preferences.PaneIdentifier.blocklist
    let preferencePaneTitle = "Blocklist"
    let toolbarItemIcon: NSImage =
        if #available(macOS 11.0, *) {
            .init(systemSymbolName: "hand.raised", accessibilityDescription: "Blocklist")!
        } else {
            .init(named: NSImage.preferencesGeneralName)!  // unused
        }

    override var nibName: NSNib.Name? { "BlocklistViewController" }

    // MARK: - Views

    private var stackView: NSStackView!

    private var descriptionLabel: NSTextField!
    private var invertBlocklistCheckBox: NSButton!
    private var blocklistTableView: EditableTableView!

    private var blocklistObserver: DefaultsObservation?

    private enum Identifier {
        static let ruleColumn = NSUserInterfaceItemIdentifier(rawValue: "RuleColumn")

        static let cell = NSUserInterfaceItemIdentifier(rawValue: "RuleCell")
    }

    override func loadView() {
        super.loadView()

        // We're not using auto-layout, so need to set a preferred content size for Preferences window to show
        preferredContentSize = .zero

        descriptionLabel = NSTextField(labelWithString: "Blocked websites are ignored by default. A rule like \"example.com\"\ndisables Accelerate on all URLs starting with that domain. Use the asterisk\nwildcard to represent zero or more of any character, e.g., *.example.com\nmatches \"my.example.com\" and \"test.example.com\".")
        descriptionLabel.maximumNumberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.alignment = .center
        descriptionLabel.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)

        invertBlocklistCheckBox = NSButton(checkboxWithTitle: "Invert blocklist (enable extension only on these websites)", target: nil, action: #selector(updateInvertBlocklist(_:)))
        invertBlocklistCheckBox.state = Defaults[.isBlocklistInverted] ? .on : .off
        invertBlocklistCheckBox.toolTip = "Invert blocklist to enable extension only on these websites"
        invertBlocklistCheckBox.target = self
        invertBlocklistCheckBox.action = #selector(updateInvertBlocklist(_:))

        blocklistTableView = EditableTableView()
        blocklistTableView.tableView.dataSource = self
        blocklistTableView.tableView.delegate = self
        blocklistTableView.tableView.usesAlternatingRowBackgroundColors = true
        blocklistTableView.tableView.register(nil, forIdentifier: Identifier.cell)
        blocklistTableView.tableView.registerForDraggedTypes([.string])
        blocklistTableView.tableView.headerView = nil
        blocklistTableView.tableView.setAccessibilityLabel("Blocklist")

        if #available(macOS 11.0, *) {
            blocklistTableView.tableView.style = .plain
        }

        let blocklistTableViewColumn = NSTableColumn(identifier: Identifier.ruleColumn)
        blocklistTableView.tableView.addTableColumn(blocklistTableViewColumn)

        bindTableViewActions()

        stackView = NSStackView(views: [descriptionLabel, invertBlocklistCheckBox, blocklistTableView])
        stackView.orientation = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)

        addVisualConstraints([
            "H:|-(>=32)-[stackView]-(>=32)-|",
            "V:[blocklistTableView(256)]",
            "V:|-[stackView]-|",
        ])

        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Add observer for changes to blocklist
        // NOTE: Registering this observer will immediately call it
        blocklistObserver = Defaults.observe(.blocklist) { _ in self.blocklistTableView.reload() }
    }

    @objc private func updateInvertBlocklist(_ sender: NSButton) {
        Defaults[.isBlocklistInverted] = sender.state == .on
    }

    private func bindTableViewActions() {
        blocklistTableView.addAction = { [unowned self] _ in
            // Add new cell if there isn't an empty cell already
            if Defaults[.blocklist].isEmpty || !Defaults[.blocklist].last!.isEmpty {
                Defaults[.blocklist].append("")
                beginEditing(at: Defaults[.blocklist].endIndex - 1)
            }
        }

        blocklistTableView.removeAction = { [unowned self] _, index in
            if let index {
                let rule = Defaults[.blocklist].remove(at: index)
                registerUndoRemove(rule, at: index)
            }
        }

        blocklistTableView.editAction = { [unowned self] _, selectedRow in
            beginEditing(at: selectedRow)
        }
    }

    private func beginEditing(at row: Int) {
        let textfield = blocklistTableView.tableView.view(atColumn: 0, row: row, makeIfNecessary: true) as! NSTextField
        configureTextField(textfield)
        blocklistTableView.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        view.window?.makeFirstResponder(textfield)
    }

    // MARK: - Undo Manager

    private func registerUndoRemove(_ rule: String, at index: Int) {
        undoManager?.registerUndo(
            withTarget: self,
            handler: { target in
                target.registerUndoInsert(rule, at: index, new: false)
                Defaults[.blocklist].insert(rule, at: index)
            }
        )
        undoManager?.setActionName("Delete of Blocklist Rule")
    }

    private func registerUndoInsert(_: String, at index: Int, new isNew: Bool) {
        undoManager?.registerUndo(
            withTarget: self,
            handler: { target in
                target.registerUndoRemove(Defaults[.blocklist].remove(at: index), at: index)
            }
        )

        undoManager?.setActionName(isNew ? "New Blocklist Rule" : "Delete of Blocklist Rule")
    }
}

extension BlocklistViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in _: NSTableView) -> Int { Defaults[.blocklist].count }

    func tableView(_: NSTableView, didAdd rowView: NSTableRowView, forRow _: Int) {
        rowView.subviews.forEach {
            guard let textField = $0 as? NSTextField else { return }
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.centerYAnchor.constraint(equalTo: rowView.centerYAnchor, constant: -1).isActive = true
        }
    }

    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        let rule = Defaults[.blocklist][row]
        let textField: NSTextField = tableView.dequeueReusableView(withIdentifier: Identifier.ruleColumn, for: row) {
            let newTextField = NSTextField(labelWithString: rule)
            configureTextField(newTextField)
            return newTextField
        }

        textField.stringValue = rule
        return textField
    }
}

extension BlocklistViewController: NSTextFieldDelegate {
    private func configureTextField(_ textField: NSTextField) {
        textField.isEditable = true
        textField.usesSingleLineMode = true
        textField.identifier = Identifier.ruleColumn
        textField.delegate = self
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, textField.identifier == Identifier.ruleColumn {
            let row = blocklistTableView.tableView.row(for: textField)
            if row > -1 {
                if textField.stringValue.isEmpty {
                    Defaults[.blocklist].remove(at: row)
                } else {
                    Defaults[.blocklist][row] = textField.stringValue.trimmingCharacters(in: .whitespaces)
                }
            }
        }
    }
}
