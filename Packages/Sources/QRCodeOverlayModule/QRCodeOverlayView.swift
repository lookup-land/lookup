// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SharedModels
import SharedViews
import SwiftUI

public struct QRCodeOverlayView: View {
    @ObserveInjection private var iO

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var store: StoreOf<QRCodeOverlayReducer>

    public init(store: StoreOf<QRCodeOverlayReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            if
                let qrCode = store.qrCode,
                let urlString = qrCode.data.payloadStringValue,
                let url = URL(string: urlString),
                let host = url.host(),
                qrCode.date.timeIntervalSince(store.prevPressDate) > 2
            {
                Button {
                    store.send(.onPress, animation: .smooth)
                } label: {
                    HStack {
                        Text(host)
                            .foregroundColor(.primary)
                            .style(.body)
                            .lineLimit(1)
                            .frame(maxWidth: 200)
                            .fixedSize()

                        Image("outline.box.arrow.in")
                            .resizable()
                            .svgFill(color: .blue)
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(BlurBackground())
                .cornerRadius(24)
                .transition(.blurReplace)
            }
        }
        .onReceive(timer) { input in
            store.send(.onTimer(input), animation: .smooth)
        }
        .coordinateSpace(name: "screen")
        .enableInjection()
    }
}
