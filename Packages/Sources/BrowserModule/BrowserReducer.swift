// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Extensions
import Foundation
import SharedModels
import SharedViews
import WebKit

@Reducer
public struct BrowserReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var tab: Tab

        public var isGoBackEnabled = false
        public var isGoForwardEnabled = false
        public var isPageLoading = false
        public var messageQueue = [String]()
        public var prevWebViewScrollOffset = CGFloat.zero
        public var addressBarOffset = CGFloat.zero

        public var addressBarNavButtonsOpacity: CGFloat {
            CGFloat.linearInterpolation(
                start: 1,
                end: 0,
                progress: min(addressBarOffset / (64 * 0.8), 1)
            )
        }

        public var addressBarPadding: CGFloat {
            CGFloat.linearInterpolation(
                start: 16,
                end: 10,
                progress: addressBarOffset / 64
            )
        }

        public var addressBarAddressPadding: CGFloat {
            CGFloat.linearInterpolation(
                start: 4,
                end: 0,
                progress: addressBarOffset / 64
            )
        }

        public var addressBarAddressFontScale: CGFloat {
            CGFloat.linearInterpolation(
                start: 1,
                end: 0.9,
                progress: addressBarOffset / 64
            )
        }

        public init(tab: Tab) {
            self.tab = tab
        }
    }

    public enum Action {
        case delegate(Delegate)
        case onCloseBrowser
        case onOpenBrowser
        case onReload
        case onGoBack
        case onGoForward
        case onNewTab
        case setIsPageLoading(Bool)
        case onPageLoadStart
        case onPageLoadContent
        case onPageLoadEnd
        case onMessage(tab: Tab, message: String)
        case onPageScroll
        case onPageScrollEnd(willDecelerate: Bool)
    }

    public enum Delegate: Equatable {
        case openBrowser
        case closeBrowser
        case setHTMLMetadata(tab: Tab, htmlMetadata: HTMLMetadata)
        case setScene(tab: Tab, scene: LayersScene)
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case .onCloseBrowser:
                return .send(.delegate(.closeBrowser))

            case .onOpenBrowser:
                return .send(.delegate(.openBrowser))

            case .onReload:
                state.tab.webView.reload()
                return .none

            case .onGoBack:
                state.tab.webView.goBack()
                return .none

            case .onGoForward:
                state.tab.webView.goForward()
                return .none

            case .onNewTab:
                state.isGoBackEnabled = state.tab.webView.canGoBack
                state.isGoForwardEnabled = state.tab.webView.canGoForward

                return .none

            case let .setIsPageLoading(value):
                state.isPageLoading = value
                return .none

            case .onPageLoadStart:
                state.addressBarOffset = 0
                state.prevWebViewScrollOffset = 0
                state.tab.layersEnabled = false

                return .run { [] send in
                    await send(.setIsPageLoading(true))
                }

            case .onPageLoadContent:
                return .run { [tab = state.tab] send in
                    await send(.onNewTab)

                    let htmlMetadata = try await tab.webView.getHTMLMetadata()

                    if htmlMetadata.initialBrowserVisibility == .visible {
                        await send(.delegate(.openBrowser), animation: .smooth)
                    }

                    await send(.delegate(.setHTMLMetadata(tab: tab, htmlMetadata: htmlMetadata)))
                }

            case .onPageLoadEnd:
                return .send(.setIsPageLoading(false))

            case .onPageScroll:
                let scrollView = state.tab.webView.scrollView
                let offset = scrollView.contentOffset.y

                let isNewPage = state.addressBarOffset == 0 && state.prevWebViewScrollOffset == 0

                if !isNewPage,
                   scrollView.isScrollEnabled,
                   !scrollView.isBouncing
                {
                    state.addressBarOffset = min(
                        max(
                            state.addressBarOffset + offset - state.prevWebViewScrollOffset,
                            0
                        ),
                        64
                    )
                }

                state.prevWebViewScrollOffset = offset

                return .none

            case let .onPageScrollEnd(willDecelerate: decelerate):
                let scrollView = state.tab.webView.scrollView
                let offset = scrollView.contentOffset.y

                if offset < 64 {
                    state.addressBarOffset = 0
                } else if !decelerate {
                    if state.addressBarOffset < 40 {
                        state.addressBarOffset = 0
                    } else {
                        state.addressBarOffset = 64
                    }
                }

                return .none

            case let .onMessage(tab: tab, message: message):
                guard let payload = try? JSONDecoder().decode(EventMessage.self, from: Data(message.utf8)) else {
                    return .none
                }

                switch payload.data {
                case let .startScene(scene):
                    return .send(.delegate(.setScene(tab: tab, scene: scene)))
                case let .updateScene(scene):
                    return .send(.delegate(.setScene(tab: tab, scene: scene)))
                case .hideBrowser:
                    return .send(.onCloseBrowser, animation: .smooth)
                case .initialize:
                    state.tab.layersEnabled = true
                    return .none
                }
            }
        }
    }
}
