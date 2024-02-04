//
//  SnackbarLocation.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/21/22.
//

import Defaults
import Foundation

enum SnackbarLocation: Int, CaseIterable, CustomStringConvertible, Codable, Defaults.Serializable {
    case bottomCenter = 0
    case bottomLeft, bottomRight, topCenter, topLeft, topRight, none

    var description: String {
        switch self {
        case .bottomCenter: "Bottom Center"
        case .bottomLeft: "Bottom Left"
        case .bottomRight: "Bottom Right"
        case .topCenter: "Top Center"
        case .topLeft: "Top Left"
        case .topRight: "Top Right"
        case .none: "Hidden"
        }
    }
}
