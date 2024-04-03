// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

struct RemoveTabOverlayView: View {
    let visible: Bool

    var body: some View {
        VStack {
            if visible {
                HStack(alignment: .center) {
                    Spacer()

                    Image("outline.cross")
                        .resizable()
                        .svgFill(color: .primary)
                        .frame(width: 16, height: 16)

                    Text("Close")
                        .style(.body, weight: .bold)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.red)
                .transition(.offset(y: -100))
            }

            Spacer()
        }
    }
}
