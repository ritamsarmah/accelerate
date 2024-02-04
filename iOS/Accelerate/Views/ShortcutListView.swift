//
//  ShortcutListView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/5/21.
//

import Defaults
import SwiftUI

struct ShortcutListView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @Default(.shortcuts) private var shortcuts: [Shortcut]

    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(shortcuts) {
                    ShortcutRow(shortcut: $0)
                }
                .onMove(perform: viewModel.moveShortcuts)
                .onDelete(perform: viewModel.deleteShortcuts)
            }
            .sheet(isPresented: $viewModel.isPresentingDetail) {
                ShortcutDetailView(viewModel: .init(shortcut: viewModel.detailShortcut))
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if viewModel.editMode == .active {
                        Button("Reset All", role: .destructive) {
                            viewModel.isAlertPresented = true
                        }
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()

                    if shortcuts.count < Shortcut.maximumShortcuts {
                        Button {
                            viewModel.createShortcut()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .environment(\.editMode, $viewModel.editMode)
            .navigationTitle(Text("Shortcuts"))
        }
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(alertInfo: viewModel.alertInfo)
        }
        .environmentObject(viewModel)
    }
}

extension ShortcutListView {

    struct ShortcutRow: View {

        var shortcut: Shortcut

        @EnvironmentObject var viewModel: ViewModel

        var body: some View {
            NavigationLink {
                ShortcutDetailView(viewModel: .init(shortcut: shortcut))
            } label: {
                HStack {
                    Image(systemName: shortcut.action.iconSystemName)
                        .frame(width: 30)
                    VStack {
                        Text(shortcut.description)
                    }
                }
            }
        }
    }
}

struct ShortcutListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShortcutListView()
            ShortcutListView()
                .previewDevice("iPod touch (7th generation)")
            ShortcutListView()
                .previewDevice("iPad Pro (9.7-inch)")
        }
    }
}

class ShortcutListViewController: UIHostingController<ShortcutListView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ShortcutListView())
    }
}
