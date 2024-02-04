//
//  BlocklistView.swift
//  BlocklistView
//
//  Created by Ritam Sarmah on 9/9/21.
//

import Defaults
import SwiftUI

struct BlocklistView: View {

    @Default(.blocklist) private var blocklist: [String]

    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                Section {
                    if blocklist.isEmpty {
                        Text("Your blocklist is empty. Add website rules with the '+' button.")
                            .lineLimit(nil)
                            .foregroundColor(.secondary)
                            .padding([.vertical], 8)
                    } else {
                        ForEach(blocklist, id: \.self) {
                            Text($0)
                            // TODO: Add edit on tap
                        }
                        .onMove(perform: viewModel.moveRules)
                        .onDelete(perform: viewModel.deleteRules)
                    }
                }
                Section(footer: Text("When inverted, Accelerate will be enabled only on websites matching blocklist rules.")) {
                    Defaults.Toggle("Invert Blocklist", key: .isBlocklistInverted)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        AlertInfo.showAlert(.blocklistHelp)
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()

                    Button {
                        AlertInfo.showAlert(.blocklistAddRule)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle(Text("Blocklist"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BlocklistView_Previews: PreviewProvider {
    static var previews: some View {
        BlocklistView()
    }
}

class BlocklistViewController: UIHostingController<BlocklistView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BlocklistView())
    }
}
