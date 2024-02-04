//
//  ShortcutDetailView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/5/21.
//

import Defaults
import SwiftUI

struct ShortcutDetailView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        if viewModel.isNewShortcut {
            // Present as sheet
            NavigationView {
                form
            }
        } else {
            // Present as detail
            form
        }
    }

    var form: some View {
        Form {
            Section {
                Picker("Action", selection: $viewModel.actionDescription) {
                    ForEach(Shortcut.Action.allCases.map(\.defaultDescription), id: \.self) { Text($0) }
                }
                .pickerStyle(.automatic)

                ValueField()
            }

            Section {
                HStack {
                    Text("Shortcut Key")
                    Spacer()
                    TextField("Shortcut Key", text: $viewModel.keyInput, prompt: Text("None"))
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: viewModel.keyInput, perform: viewModel.validateKeyInput)
                }
            } footer: {
                Text("Enter a single key that triggers the action when pressed.")
            }

            Section {
                Toggle("Show Notification", isOn: $viewModel.showSnackbar)
                Toggle("Show in Popup Menu", isOn: $viewModel.showInPopup)
            } footer: {
                Text("Notifications are displayed over the webpage. Popup menu can be activated from Safari's toolbar.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .opacity(viewModel.isNewShortcut ? 1 : 0)
                .disabled(!viewModel.isNewShortcut)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveShortcut()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!viewModel.isValidShortcut)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(viewModel)
    }
}

extension ShortcutDetailView {

    struct ValueField: View {

        @EnvironmentObject var viewModel: ViewModel

        @ViewBuilder
        var body: some View {
            switch viewModel.actionDescription {
            case Shortcut.Action.slowDown().defaultDescription, Shortcut.Action.speedUp().defaultDescription:
                NumberTextField(
                    title: "Speed Interval",
                    value: $viewModel.associatedValue,
                    placeholder: 0.25,
                    formatter: Shortcut.Action.rateFormatter
                )

            case Shortcut.Action.setRate().defaultDescription:
                HStack {
                    Toggle("Use Default Speed", isOn: $viewModel.useDefaultSpeed)
                }

                if !viewModel.useDefaultSpeed {
                    NumberTextField(
                        title: "Speed Value",
                        value: $viewModel.associatedValue,
                        placeholder: 2,
                        formatter: Shortcut.Action.rateFormatter
                    )
                }

            case Shortcut.Action.skipBackward().defaultDescription, Shortcut.Action.skipForward().defaultDescription:
                NumberTextField(
                    title: "Skip Interval",
                    value: $viewModel.associatedValue,
                    placeholder: 10,
                    formatter: Shortcut.Action.timeFormatter
                )

            default:
                EmptyView()
            }
        }
    }
}

struct ShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutDetailView(viewModel: .init(shortcut: nil))
    }
}
