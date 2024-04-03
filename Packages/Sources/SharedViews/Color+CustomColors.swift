// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

public extension UIColor {
    static let earthGreen = UIColor(red: 123 / 255, green: 224 / 255, blue: 168 / 255, alpha: 1.0)

    static let treeGreen = UIColor(red: 0, green: 130 / 255, blue: 57 / 255, alpha: 1.0)
}

public extension Color {
    static let earthGreen = Color(UIColor.earthGreen)

    static let treeGreen = Color(UIColor.treeGreen)

    static let green = Color("green")
}
