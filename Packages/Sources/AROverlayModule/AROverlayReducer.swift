// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import BrowserModule
import ComposableArchitecture
import Foundation
import NavigatorModule
import NewTabModule
import QRCodeOverlayModule
import SharedModels

@Reducer
public struct AROverlayReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var navigator = NavigatorReducer.State()
        @Presents public var addNewTab: NewTabReducer.State?
        public var browser = BrowserReducer.State(tab: Tab())
        public var qrCodeOverlay = QRCodeOverlayReducer.State()

        public var qrCode: QRCode? {
            didSet {
                qrCodeOverlay.qrCode = qrCode
            }
        }

        public var tabs: IdentifiedArrayOf<Tab> = [] {
            didSet {
                navigator.tabs = tabs
            }
        }

        public var selectedTab: Tab? {
            didSet {
                navigator.selectedTab = selectedTab

                if let tab = selectedTab {
                    browser.tab = tab
                }
            }
        }

        public var isBrowserVisible = false {
            didSet {
                navigator.isBrowserVisible = isBrowserVisible
            }
        }

        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case navigator(NavigatorReducer.Action)
        case addNewTab(PresentationAction<NewTabReducer.Action>)
        case browser(BrowserReducer.Action)
        case qrCodeOverlay(QRCodeOverlayReducer.Action)
        case openNewTab(Tab, URL)
    }

    public enum Delegate: Equatable {
        case insertTab(Tab, at: Int = 0)
        case removeTab(Tab)
        case selectTab(Tab)
        case setHTMLMetadata(tab: Tab, htmlMetadata: HTMLMetadata)
        case setScene(tab: Tab, scene: LayersScene)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.navigator, action: \.navigator) {
            NavigatorReducer()
        }
        Scope(state: \.browser, action: \.browser) {
            BrowserReducer()
        }
        Scope(state: \.qrCodeOverlay, action: \.qrCodeOverlay) {
            QRCodeOverlayReducer()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case .navigator(.delegate(.openNewTab)):
                state.addNewTab = NewTabReducer.State(
                    tab: Tab()
                )
                return .none

            case let .navigator(.delegate(.removeTab(tab))):
                return .send(.delegate(.removeTab(tab)))

            case let .navigator(.delegate(.selectTab(tab))):
                return .send(.delegate(.selectTab(tab)))

            case .navigator(.onOpenBrowser):
                state.isBrowserVisible = true

                return .none

            case .navigator:
                return .none

            case .addNewTab(.presented(.onCancel)):
                state.addNewTab = nil

                return .none

            case .addNewTab(.presented(.onSubmit)):
                guard let addNewTab = state.addNewTab else {
                    return .none
                }

                guard let tab = state.addNewTab?.tab else {
                    return .none
                }

                guard !addNewTab.query.isEmpty,
                      let url = try? URL.parseURL(urlString: addNewTab.query)
                else {
                    state.addNewTab = nil
                    return .none
                }

                state.addNewTab = nil

                return .send(.openNewTab(tab, url))

            case .addNewTab:
                return .none

            case .browser(.delegate(.closeBrowser)):
                state.isBrowserVisible = false
                return .none

            case .browser(.delegate(.openBrowser)):
                state.isBrowserVisible = true
                return .none

            case let .browser(.delegate(.setHTMLMetadata(tab: tab, htmlMetadata: htmlMetadata))):
                return .send(.delegate(.setHTMLMetadata(tab: tab, htmlMetadata: htmlMetadata)))

            case let .browser(.delegate(.setScene(tab: tab, scene: scene))):
                return .send(.delegate(.setScene(tab: tab, scene: scene)))

            case .browser:
                return .none

            case .qrCodeOverlay(.delegate(.onPress)):
                let tab = Tab()

                guard let urlString = state.qrCode?.data.payloadStringValue else {
                    return .none
                }

                state.qrCode = nil

                guard let url = try? URL.parseURL(urlString: urlString) else {
                    return .none
                }

                return .send(.openNewTab(tab, url))

            case .qrCodeOverlay(.delegate(.onExpired)):
                state.qrCode = nil
                return .none

            case .qrCodeOverlay:
                return .none

            case let .openNewTab(tab, url):
                tab.webView.loadURL(url: url)

                state.browser.tab = tab

                state.addNewTab = nil

                return .run { [] send in
                    await send(
                        .delegate(.insertTab(tab, at: 0))
                    )

                    await send(
                        .delegate(.selectTab(tab))
                    )
                }
            }
        }
        .ifLet(\.$addNewTab, action: \.addNewTab) {
            NewTabReducer()
        }
    }
}
