//
//  TutorialViewController.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 7/3/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import Defaults
import SafariServices.SFSafariApplication

class TutorialViewController: NSViewController {

    private enum Page: Int, CaseIterable {
        case welcome = 0  // Introduction
        case shortcuts  // If new user, show default shortcuts. If prior user, note migration.
        case enable  // (Optional) Button to enable extension in Safari
        case exit

        mutating func next() {
            self = Page(rawValue: rawValue + 1) ?? .exit
        }

        mutating func back() {
            self = Page(rawValue: rawValue - 1) ?? .welcome
        }
    }

    private var page: Page = .welcome {
        didSet { DispatchQueue.main.async { self.updateViews() } }
    }

    // MARK: - Views

    private var stackView: NSStackView!

    private var imageView: NSImageView!
    private var titleLabel: NSTextField!
    private var subtitleLabel: NSTextField!

    private var nextButton: NSButton!
    private var backButton: NSButton!

    private var actionButton: NSButton!
    private var actionButtonLabel: NSTextField!

    override func loadView() {
        super.loadView()

        imageView = NSImageView(image: NSImage(named: "AppIcon")!)

        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 24)
        titleLabel.alignment = .center

        subtitleLabel = NSTextField(labelWithString: "")
        subtitleLabel.maximumNumberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.alignment = .center

        nextButton = NSButton(title: "Continue", target: self, action: #selector(next))

        backButton = NSButton(title: "Back", target: self, action: #selector(back))
        backButton.isHidden = true

        actionButton = NSButton(title: "", target: self, action: nil)

        actionButtonLabel = NSTextField(labelWithString: "")
        actionButtonLabel.textColor = .secondaryLabelColor

        stackView = NSStackView(views: [imageView, titleLabel, subtitleLabel, actionButton, actionButtonLabel])
        stackView.orientation = .vertical
        stackView.detachesHiddenViews = true

        stackView.setHuggingPriority(.required, for: .vertical)
        stackView.setCustomSpacing(20, after: subtitleLabel)

        view.addSubview(stackView)
        view.addSubview(nextButton)
        view.addSubview(backButton)

        addVisualConstraints([
            "V:|-[stackView]-[backButton]-|",
            "H:|-[stackView]-|",
            "V:[imageView(64)]",
            "H:[imageView(64)]",
            "V:[nextButton]-|",
            "H:[backButton]-[nextButton]-|",
        ])

        view.widthAnchor.constraint(equalToConstant: 512).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        updateViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self, selector: #selector(updateActionButtonLabel),
            name: NSApplication.didBecomeActiveNotification, object: nil
        )
    }

    private func updateViews() {
        backButton.isHidden = page == .welcome
        nextButton.isEnabled = true

        actionButton.isHidden = true
        actionButtonLabel.isHidden = true

        switch page {
        case .welcome:
            titleLabel.stringValue = "Welcome to Accelerate"
            subtitleLabel.stringValue = "Accelerate is a powerful, fully customizable Safari extension for controlling video playback and speed."

        case .shortcuts:
            if PreferenceMigrator.shared.isLegacyDefaultsEmpty {
                titleLabel.stringValue = "Keyboard Shortcuts"
                subtitleLabel.stringValue = "Control videos across your favorite websites with your keyboard. Use the default shortcuts, or create and customize your own."
            } else {
                titleLabel.stringValue = "Migrate Existing Preferences"
                subtitleLabel.stringValue = "This version includes a re-designed interface and options for shortcuts and settings. Your existing preferences will be migrated."
            }

        case .enable:
            nextButton.isEnabled = true
            updateActionButtonLabel()

            titleLabel.stringValue = "Enable Safari Extension"
            subtitleLabel.stringValue = "Check that the Accelerate extension is enabled in Safari to get started."

            actionButton.title = "Open Safari Extension Preferences"
            actionButton.action = #selector(openSafariExtensionPreferences)
            actionButton.isHidden = false
            actionButtonLabel.isHidden = false

        case .exit:
            DispatchQueue.main.async {
                self.view.window?.orderOut(nil)
                (NSApplication.shared.delegate as! AppDelegate).preferencesWindowController.show(preferencePane: .general)
            }
        }
    }

    @objc private func next() {
        page.next()
    }

    @objc private func back() {
        page.back()
    }

    @objc private func openSafariExtensionPreferences() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.ritamsarmah.Accelerate.Extension")
    }

    @objc private func updateActionButtonLabel() {
        if case .enable = page {
            // Set action button label to empty string since completion block takes a while to update label
            actionButtonLabel.stringValue = ""

            SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "com.ritamsarmah.Accelerate.Extension") { state, _ in
                DispatchQueue.main.async {
                    if let state {
                        self.actionButtonLabel.stringValue = state.isEnabled ? "Extension Status: Enabled" : "Extension Status: Disabled"
                        self.actionButtonLabel.textColor = state.isEnabled ? .systemGreen : .secondaryLabelColor

                        if !self.actionButtonLabel.isHidden {
                            self.nextButton.isEnabled = state.isEnabled
                        }
                    } else {
                        self.actionButtonLabel.stringValue = "Extension Status: Not Detected"
                    }
                }
            }
        }
    }

    // No implementation needed, just needed for keeping one radio button at a time, and will check state of button directly later
    @objc private func updateMigrationState(_: NSButton) {}
}
