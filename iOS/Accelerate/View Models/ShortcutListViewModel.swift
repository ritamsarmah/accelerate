//
//  ShortcutListViewModel.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 11/11/21.
//

import Defaults
import SwiftUI

extension ShortcutListView {

    class ViewModel: ObservableObject {

        @Published private(set) var detailShortcut: Shortcut?
        @Published var isPresentingDetail = false
        @Published var isAlertPresented = false
        @Published var editMode: EditMode = .inactive

        let alertInfo = AlertInfo(
            title: "Reset Shortcuts?",
            message: "This option will reset your shortcuts to the defaults.",
            primaryButtonText: "Cancel",
            primaryButtonType: .cancel,
            secondaryButtonText: "Reset",
            secondaryButtonType: .destructive,
            secondaryButtonAction: { Defaults.reset(Defaults.Keys.allShortcutKeys) }
        )

        func createShortcut() {
            detailShortcut = nil
            isPresentingDetail = true
        }

        func moveShortcuts(from source: IndexSet, to destination: Int) {
            Defaults[.shortcuts].move(fromOffsets: source, toOffset: destination)
        }

        func deleteShortcuts(at offsets: IndexSet) {
            Defaults[.shortcuts].remove(atOffsets: offsets)
        }

        func editShortcut(_ shortcut: Shortcut) {
            detailShortcut = shortcut
            isPresentingDetail = true
        }
    }
}
