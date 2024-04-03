// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import BrowserModule
import ComposableArchitecture
import Extensions
import Inject
import NavigatorModule
import NewTabModule
import QRCodeOverlayModule
import SharedViews
import SwiftUI

public struct AROverlayView: View {
    @ObserveInjection private var iO

    @Bindable var store: StoreOf<AROverlayReducer>

    public init(store: StoreOf<AROverlayReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            NavigatorView(
                store: store.scope(
                    state: \.navigator,
                    action: \.navigator
                )
            )

            VStack {
                Spacer()

                QRCodeOverlayView(
                    store: store.scope(
                        state: \.qrCodeOverlay,
                        action: \.qrCodeOverlay
                    )
                )
                .padding(
                    .bottom,
                    store.addNewTab != nil ? 12 : !store.tabs.isEmpty ? 32 : 0
                )

                Presenter(
                    item: $store.scope(state: \.addNewTab, action: \.addNewTab)
                ) { store in
                    NewTabView(store: store)
                }
            }

            BrowserView(store: store.scope(
                state: \.browser,
                action: \.browser
            ))
            .offset(
                y: store.isBrowserVisible ? 0 : UIScreen.dimensions.height
            )
        }
        .coordinateSpace(name: "screen")
        .enableInjection()
    }
}
