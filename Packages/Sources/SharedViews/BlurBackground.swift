// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

public struct BlurBackground: UIViewRepresentable {
    var style: UIBlurEffect.Style

    public init(style: UIBlurEffect.Style = .prominent) {
        self.style = style
    }

    public func makeUIView(context _: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: nil)
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
