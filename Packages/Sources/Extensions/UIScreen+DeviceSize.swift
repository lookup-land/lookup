// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import UIKit

public struct UIScreenDimensions {
    public var width = UIScreen.main.bounds.size.width
    public var height = UIScreen.main.bounds.size.height
}

public extension UIScreen {
    static let dimensions = UIScreenDimensions()
}
