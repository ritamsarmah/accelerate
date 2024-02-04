//
//  GeneralViewController.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 2/8/19.
//  Copyright © 2019 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import MASShortcut
import Preferences
import SafariServices.SFSafariApplication

class GeneralViewController: NSViewController, PreferencePane {

    // MARK: - PreferencePane

    let preferencePaneIdentifier = Preferences.PaneIdentifier.general
    let preferencePaneTitle = "General"
    let toolbarItemIcon: NSImage =
        if #available(macOS 11.0, *) {
            .init(systemSymbolName: "gearshape", accessibilityDescription: "General")!
        } else {
            .init(named: NSImage.preferencesGeneralName)!  // unused
        }

    override var nibName: NSNib.Name? { "GeneralViewController" }

    // MARK: - Views

    private var gridView: NSGridView!

    private var snackbarLocationLabel: NSTextField!
    private var snackbarLocationButton: NSPopUpButton!
    private var snackbarDescriptionLabel: NSTextField!

    private var defaultRateLabel: NSTextField!
    private var defaultRateTextField: NSTextField!

    private var minimumRateLabel: NSTextField!
    private var minimumRateTextField: NSTextField!

    private var maximumRateLabel: NSTextField!
    private var maximumRateTextField: NSTextField!

    private var buttonStackView: NSStackView!
    private var tipButton: NSButton!
    private var restoreButton: NSButton!
    private var helpButton: NSButton!

    private var bindings: [String: NSView]!

    override func loadView() {
        super.loadView()

        // We're not using auto-layout, so need to set a preferred content size for Preferences window to show
        preferredContentSize = .zero

        // Snackbar location label
        snackbarLocationLabel = NSTextField(labelWithString: "Notification location:")
        snackbarLocationLabel.alignment = .right

        // Snackbar location button
        snackbarLocationButton = NSPopUpButton()
        snackbarLocationButton.addItems(withTitles: SnackbarLocation.allCases.map(\.description))
        snackbarLocationButton.target = self
        snackbarLocationButton.action = #selector(updateSnackbarLocation)
        snackbarLocationButton.setAccessibilityLabel("Notification Location")

        // Snackbar description label
        snackbarDescriptionLabel = NSTextField(labelWithString: "Each shortcut must also have its\nnotification enabled to show.")
        snackbarDescriptionLabel.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)

        // Default rate label
        defaultRateLabel = NSTextField(labelWithString: "Default playback speed:")
        defaultRateLabel.alignment = .right

        // Default rate text field
        defaultRateTextField = NSTextField()
        defaultRateTextField.formatter = Shortcut.Action.rateFormatter
        defaultRateTextField.refusesFirstResponder = true
        defaultRateTextField.target = self
        defaultRateTextField.action = #selector(updateDefaultRate)
        defaultRateTextField.setAccessibilityLabel("Default Playback Speed")

        // Minimum rate label
        minimumRateLabel = NSTextField(labelWithString: "Minimum playback speed:")
        minimumRateLabel.alignment = .right

        // Minimum rate text field
        minimumRateTextField = NSTextField()
        minimumRateTextField.formatter = Shortcut.Action.rateFormatter
        minimumRateTextField.refusesFirstResponder = true
        minimumRateTextField.target = self
        minimumRateTextField.action = #selector(updateMinimumRate)
        minimumRateTextField.setAccessibilityLabel("Minimum Playback Speed")

        // Maximum rate label
        maximumRateLabel = NSTextField(labelWithString: "Maximum playback speed:")
        maximumRateLabel.alignment = .right

        // Maximum rate text field
        maximumRateTextField = NSTextField()
        maximumRateTextField.formatter = Shortcut.Action.rateFormatter
        maximumRateTextField.refusesFirstResponder = true
        maximumRateTextField.target = self
        maximumRateTextField.action = #selector(updateMaximumRate)
        maximumRateTextField.setAccessibilityLabel("Maximum Playback Speed")

        // Tip button
        tipButton = NSButton(title: "♥", target: self, action: #selector(purchaseTip(_:)))
        tipButton.setAccessibilityLabel("Leave a Tip or Review")

        // Restore button
        restoreButton = NSButton(title: "Restore Defaults", target: self, action: #selector(restoreDefaults(_:)))

        // Help button
        helpButton = NSButton.helpButton(target: self, action: #selector(openHelp(_:)))

        // Grid view
        gridView = NSGridView(views: [
            [snackbarLocationLabel, snackbarLocationButton],
            [NSGridCell.emptyContentView, snackbarDescriptionLabel],
            [defaultRateLabel, defaultRateTextField],
            [minimumRateLabel, minimumRateTextField],
            [maximumRateLabel, maximumRateTextField],
        ])

        gridView.columnSpacing = 8
        gridView.column(at: 0).xPlacement = .trailing
        gridView.row(at: 1).bottomPadding = 4
        gridView.row(at: 2).bottomPadding = 4
        gridView.row(at: 3).bottomPadding = 4

        // Center labels for text fields
        gridView.cell(atColumnIndex: 0, rowIndex: 2).yPlacement = .center
        gridView.cell(atColumnIndex: 0, rowIndex: 3).yPlacement = .center
        gridView.cell(atColumnIndex: 0, rowIndex: 4).yPlacement = .center

        gridView.setContentHuggingPriority(.required, for: .vertical)

        // Stack view
        buttonStackView = NSStackView(views: [tipButton, restoreButton, helpButton])
        buttonStackView.orientation = .horizontal
        buttonStackView.setContentHuggingPriority(.required, for: .vertical)

        // Add subviews
        view.addSubview(gridView)
        view.addSubview(buttonStackView)

        // Layout constraints
        bindings = constructViewBindings()

        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:[defaultRateTextField(64)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[defaultRateTextField(22)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[minimumRateTextField(64)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[minimumRateTextField(22)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[maximumRateTextField(64)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[maximumRateTextField(22)]", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=64)-[gridView]-(>=64)-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[gridView]-(24)-[buttonStackView]-|", options: [], metrics: nil, views: bindings),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[buttonStackView]-|", options: [], metrics: nil, views: bindings),
        ]

        constraints.forEach { view.addConstraints($0) }

        gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        updateViews()
    }

    private func updateViews() {
        snackbarLocationButton.selectItem(at: Defaults[.snackbarLocation].rawValue)
        defaultRateTextField.doubleValue = Defaults[.defaultRate]
        minimumRateTextField.doubleValue = Defaults[.minimumRate]
        maximumRateTextField.doubleValue = Defaults[.maximumRate]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(macOS 10.14, *) {
            // Nothing needed for 10.14+
        } else {
            // High Sierra requires explicit height constraints to avoid stretching
            view.layoutSubtreeIfNeeded()
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[gridView(\(gridView.frame.height))]", options: [], metrics: nil, views: bindings))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[buttonStackView(\(buttonStackView.frame.height))]", options: [], metrics: nil, views: bindings))
        }
    }

    // MARK: - Actions

    @objc private func updateSnackbarLocation(_ sender: NSPopUpButton) {
        Defaults[.snackbarLocation] = SnackbarLocation(rawValue: sender.indexOfSelectedItem)!
    }

    @objc private func updateDefaultRate(_ sender: NSTextField) {
        Defaults[.defaultRate] = sender.doubleValue
    }

    @objc private func updateMinimumRate(_ sender: NSTextField) {
        if sender.doubleValue < Defaults[.maximumRate] {
            Defaults[.minimumRate] = sender.doubleValue
        } else {
            let alert = NSAlert()
            alert.messageText = "Invalid minimum speed"
            alert.informativeText = "The minimum speed must be less than the maximum speed of \(Defaults[.maximumRate])"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()

            // Use previous value
            sender.doubleValue = Defaults[.minimumRate]
        }
    }

    @objc private func updateMaximumRate(_ sender: NSTextField) {
        if sender.doubleValue > Defaults[.minimumRate] {
            Defaults[.maximumRate] = sender.doubleValue
        } else {
            let alert = NSAlert()
            alert.messageText = "Invalid maximum speed"
            alert.informativeText = "The maximum speed must be greater than the minimum speed of \(Defaults[.minimumRate])"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()

            // Use previous value
            sender.doubleValue = Defaults[.maximumRate]
        }
    }

    @objc private func openSafariExtensionPreferences(_: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.ritamsarmah.Accelerate.Extension")
    }

    @objc private func openHelp(_: NSButton) {
        let url = URL(string: "https://ritam.me/projects/accelerate/faq")!
        NSWorkspace.shared.open(url)
    }

    @objc private func purchaseTip(_: NSButton) {
        let alert = NSAlert()

        alert.messageText = "Thanks for using Accelerate!"
        alert.informativeText = "If you are enjoying this app, leaving a review or tip helps support future work and is greatly appreciated!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Tip (\(StoreManager.shared.localizedTipPrice ?? ""))")
        alert.addButton(withTitle: "Leave a Review")
        alert.addButton(withTitle: "Not Now")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            StoreManager.shared.purchaseTip { _ in
                DispatchQueue.main.async { self.updateViews() }
            }
        case .alertSecondButtonReturn:
            let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(1_459_809_092)?action=write-review")!
            NSWorkspace.shared.open(writeReviewURL)
        default:
            break
        }
    }

    @objc private func restoreDefaults(_: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to restore the default settings?"
        alert.informativeText = "Any custom settings will be permanently overwritten."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            Defaults.reset(Defaults.Keys.allGeneralKeys)
            updateViews()
        default:
            break
        }
    }
}
