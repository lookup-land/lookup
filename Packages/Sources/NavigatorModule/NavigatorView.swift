// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import LocationClient
import SharedViews
import SwiftUI
import TabModule

public struct NavigatorView: View {
    @ObserveInjection private var iO

    let store: StoreOf<NavigatorReducer>

    public init(store: StoreOf<NavigatorReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    if !store.isBrowserVisible {
                        Text(store.locality)
                            .foregroundColor(.white)
                            .style(.body)
                            .shadow(color: .black.opacity(0.75), radius: 2, x: 0, y: 0)
                            .transition(.blurReplace)
                    }

                    Spacer()

                    if !store.isBrowserVisible {
                        Button {} label: {
                            CompassView(
                                heading: store.heading
                            )
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 0)
                        }
                        .transition(.blurReplace)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                HStack(alignment: .bottom) {
                    Spacer()

                    Button {
                        store.send(.onOpenBrowser, animation: .smooth)
                    } label: {
                        Image("outline.chevron.up")
                            .resizable()
                            .svgFill(color: .primary)
                            .frame(width: 20, height: 20)
                            .padding([.horizontal, .top], 16)
                            .padding(.bottom, 4)
                            .contentShape(Rectangle())
                    }
                    .shadow(color: .black.opacity(0.75), radius: 2, x: 0, y: 0)
                    .padding(.leading, 40)
                    .opacity(store.selectedTab != nil ? 1 : 0)
                    .animation(.smooth, value: store.selectedTab)

                    Spacer()

                    TabBarView(
                        store: store.scope(state: \.tabBar, action: \.tabBar)
                    )
                }
                .padding(.horizontal, 16)
            }

            RemoveTabOverlayView(
                visible: store.isRemoveTabOverlayVisible
            )
        }
        .task {
            store.send(.onAppear)
        }
        .ignoresSafeArea(.keyboard)
        .enableInjection()
    }
}
