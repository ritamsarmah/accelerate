//
//  EditableTableView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/17/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults

class EditableTableView: NSView {

    var addAction: ((_ tableView: NSTableView) -> Void)?
    var removeAction: ((_ tableView: NSTableView, _ row: Int?) -> Void)?
    var editAction: ((_ tableView: NSTableView, _ row: Int) -> Void)?

    var maximumNumberOfRows = -1

    // MARK: - Views

    private lazy var tableContainer: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        return scrollView
    }()

    public lazy var tableView: NSTableView = {
        let tableView = NSTableView()
        tableView.doubleAction = #selector(editRow)
        tableView.allowsColumnResizing = false
        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        return tableView
    }()

    private lazy var editButtons: NSSegmentedControl = {
        let editButtons = NSSegmentedControl(
            images: [
                NSImage(named: NSImage.addTemplateName)!,
                NSImage(named: NSImage.removeTemplateName)!,
            ],
            trackingMode: .momentary,
            target: self,
            action: #selector(editButtonsClicked)
        )
        return editButtons
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(tableContainer)
        addSubview(editButtons)

        // Layout constraints
        let bindings = [
            "tableContainer": tableContainer,
            "editButtons": editButtons,
        ]

        bindings.forEach { $0.value.translatesAutoresizingMaskIntoConstraints = false }

        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[tableContainer]-(0)-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[tableContainer]-(16)-[editButtons]-(0)-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[editButtons]", options: [], metrics: nil, views: bindings),
        ]

        constraints.forEach { addConstraints($0) }
    }

    func reload() {
        tableView.reloadData()

        editButtons.setEnabled(tableView.numberOfRows != maximumNumberOfRows, forSegment: 0)
        editButtons.setEnabled(tableView.numberOfRows != 0, forSegment: 1)
    }

    // MARK: - Actions

    @objc private func editButtonsClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addAction?(tableView)
        case 1:
            removeAction?(tableView, tableView.selectedRow == -1 ? nil : tableView.selectedRow)
        default:
            break
        }
    }

    @objc private func editRow() {
        if tableView.clickedRow > -1 {
            editAction?(tableView, tableView.clickedRow)
        }
    }
}
