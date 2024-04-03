// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation
import SwiftUI

private struct SVGFill: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        VStack {
            ZStack {
                content
                color.blendMode(.sourceAtop)
            }
            .drawingGroup(opaque: false)
        }
    }
}

public extension View {
    func svgFill(color: Color) -> some View {
        modifier(SVGFill(color: color))
    }
}
