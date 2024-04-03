// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SwiftUI

public struct TabView: View {
    @ObserveInjection private var iO

    let store: StoreOf<TabReducer>

    let selected: Bool

    @State private var offset: CGSize

    public init(
        store: StoreOf<TabReducer>,
        selected: Bool,
        offset: CoreFoundation.CGSize = CGSize.zero
    ) {
        self.store = store
        self.selected = selected
        self.offset = offset
    }

    public var body: some View {
        Button {
            store.send(.onPress, animation: .smooth)
        } label: {
            FaviconView(htmlMetadata: store.tab.htmlMetadata)
                .transition(.move(edge: .trailing))
                .offset(
                    selected ?
                        CGSize(
                            width: offset.width * 0.8,
                            height: offset.height * 0.8
                        ) : offset
                )
                .gesture(
                    DragGesture(coordinateSpace: .named("screen"))
                        .onChanged { gesture in
                            store.send(.onToggleGesture(true), animation: .smooth)
                            offset = gesture.translation
                        }
                        .onEnded { position in
                            store.send(.onToggleGesture(false), animation: .smooth)
                            if abs(position.location.y) < 40 {
                                store.send(.onRemove, animation: .smooth)
                            } else {
                                withAnimation {
                                    offset = .zero
                                }
                            }
                        }
                )
        }
        .frame(
            width: 32,
            height: 32
        )
        .scaleEffect(selected ? 1.25 : 1)
        .animation(.smooth, value: selected)
        .transition(.identity)
        .enableInjection()
    }
}
