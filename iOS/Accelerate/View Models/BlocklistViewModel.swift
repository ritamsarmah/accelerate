//
//  BlocklistViewModel.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 12/24/21.
//

import Defaults
import Foundation

extension BlocklistView {

    class ViewModel: ObservableObject {

        func moveRules(from source: IndexSet, to destination: Int) {
            Defaults[.blocklist].move(fromOffsets: source, toOffset: destination)
        }

        func deleteRules(at offsets: IndexSet) {
            Defaults[.blocklist].remove(atOffsets: offsets)
        }
    }
}
