// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SharedViews
import SwiftUI

public struct TabBarView: View {
    @ObserveInjection private var iO

    let store: StoreOf<TabBarReducer>

    public init(store: StoreOf<TabBarReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ForEach(
                store.scope(state: \.tabReducers, action: \.tabReducers)
            ) { tabStore in
                TabView(store: tabStore, selected: tabStore.id == store.selectedTab?.id)
            }
            .animation(.smooth, value: store.tabs)

            Button {
                store.send(.onNewTabPress, animation: .smooth)
            } label: {
                ZStack {
                    Image("outline.plus")
                        .resizable()
                        .svgFill(color: .primary)
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 0)
                }
                .frame(width: 32, height: 32)
                .background(Color(.systemGray3))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 0)
            }
        }
        .frame(maxWidth: 40)
        .enableInjection()
    }
}
