// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SharedViews
import SwiftUI

public struct BrowserView: View {
    @ObserveInjection private var iO

    let store: StoreOf<BrowserReducer>

    public init(store: StoreOf<BrowserReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    ZStack {}
                        .frame(width: 48, height: 4)
                        .background(.gray)
                        .cornerRadius(16)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(.white)
                .clipShape(
                    .rect(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                )

                WebView(
                    tab: store.tab,
                    onPageLoadStart: {
                        store.send(.onPageLoadStart)
                    },
                    onPageLoadContent: {
                        store.send(.onPageLoadContent)
                    },
                    onPageLoadEnd: {
                        store.send(.onPageLoadEnd)
                    },
                    onMessage: {
                        store.send(.onMessage(tab: $0, message: $1))
                    },
                    onScroll: {
                        store.send(.onPageScroll)
                    },
                    onScrollEnd: {
                        store.send(
                            .onPageScrollEnd(willDecelerate: $0),
                            animation: .smooth
                        )
                    }
                )
                .frame(maxHeight: .infinity)
                .id(store.tab.webView)
                .onChange(of: store.tab.webView) {
                    store.send(.onNewTab)
                }
            }
            .padding(.bottom, 88 - store.addressBarOffset)

            VStack {
                Spacer()

                if let url = store.tab.webView.url {
                    VStack(spacing: 24) {
                        HStack {
                            Spacer()

                            Text(url.host ?? "")
                                .style(.body)
                                .padding(.leading, 22)
                                .lineLimit(1)
                                .scaleEffect(store.addressBarAddressFontScale)

                            Spacer()

                            Button {
                                store.send(.onReload)
                            } label: {
                                Image(
                                    store.isPageLoading ?
                                        "outline.cross" :
                                        "outline.rotate.right"
                                )
                                .resizable()
                                .svgFill(color: .primary)
                                .frame(width: 14, height: 14)
                                .padding(.trailing, 8)
                            }
                            .opacity(store.addressBarNavButtonsOpacity)
                        }
                        .padding(.vertical, store.addressBarAddressPadding)
                        .background(Color(.systemGray3).opacity(store.addressBarNavButtonsOpacity)
                        )
                        .cornerRadius(6)

                        HStack {
                            Button {
                                store.send(.onGoBack)
                            } label: {
                                Image("outline.chevron.left")
                                    .resizable()
                                    .svgFill(color: .primary)
                                    .frame(width: 20, height: 20)
                                    .opacity(store.isGoBackEnabled ? 1 : 0.4)
                            }
                            .disabled(!store.isGoBackEnabled)

                            Spacer()

                            Button {
                                store.send(.onGoForward)
                            } label: {
                                Image("outline.chevron.right")
                                    .resizable()
                                    .svgFill(color: .primary)
                                    .frame(width: 20, height: 20)
                                    .opacity(store.isGoForwardEnabled ? 1 : 0.4)
                            }
                            .disabled(!store.isGoForwardEnabled)

                            Spacer()

                            Button {
                                store.send(.onCloseBrowser, animation: .smooth)
                            } label: {
                                Image("logo-mark")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .grayscale(store.tab.layersEnabled ? 0 : 1)
                            }

                            Spacer()

                            ShareLink(item: url) {
                                Image("outline.box.arrow.out")
                                    .resizable()
                                    .svgFill(color: .primary)
                                    .frame(width: 20, height: 20)
                            }

                            Spacer()

                            Button {} label: {
                                Image("outline.box.squared")
                                    .resizable()
                                    .svgFill(color: .primary)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .opacity(store.addressBarNavButtonsOpacity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, store.addressBarPadding)
                    .background(Color(.systemGray6))
                    .offset(x: 0, y: store.addressBarOffset)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .enableInjection()
    }
}
