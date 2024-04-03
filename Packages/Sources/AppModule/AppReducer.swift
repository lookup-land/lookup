// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ARContainerModule
import AROverlayModule
import ComposableArchitecture
import Foundation
import LocationClient
import SharedModels

@Reducer
public struct AppReducer {
    @Dependency(\.locationClient) var locationClient

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var arOverlay = AROverlayReducer.State()
        public var arContainer = ARContainerReducer.State()

        public var tabs: IdentifiedArrayOf<Tab> = [] {
            didSet {
                arOverlay.tabs = tabs
                arContainer.tabs = tabs
            }
        }

        public init() {}

        public var selectedTabID: UUID? {
            didSet {
                arOverlay.selectedTab = selectedTab
            }
        }

        public var selectedTab: Tab? {
            tabs.first { $0.id == selectedTabID }
        }

        public var scenes: [LayersScene] {
            tabs.compactMap { $0.scene }
        }
    }

    public enum Action {
        case arOverlay(AROverlayReducer.Action)
        case arContainer(ARContainerReducer.Action)
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.arOverlay, action: \.arOverlay) {
            AROverlayReducer()
        }
        Scope(state: \.arContainer, action: \.arContainer) {
            ARContainerReducer()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case let .arOverlay(.delegate(.insertTab(tab, at: index))):
                state.tabs.insert(tab, at: index)
                return .none

            case let .arOverlay(.delegate(.removeTab(tab))):
                tab.webView.configuration.userContentController.removeAllScriptMessageHandlers()

                state.tabs.remove(id: tab.id)

                if tab.id == state.selectedTabID {
                    state.selectedTabID = nil
                }

                try? state.arContainer.sceneRenderer.drawScene(
                    scenes: state.scenes
                )

                return .none

            case let .arOverlay(.delegate(.selectTab(tab))):
                if state.selectedTabID == tab.id {
                    state.arOverlay.isBrowserVisible = true
                }

                state.selectedTabID = tab.id

                state.tabs = IdentifiedArray(
                    uniqueElements: state.tabs.sorted {
                        $0.id == state.selectedTabID &&
                            $1.id != state.selectedTabID
                    }
                )

                return .none

            case let .arOverlay(.delegate(.setHTMLMetadata(tab: tab, htmlMetadata: htmlMetadata))):
                if let tabIndex = state.tabs.firstIndex(where: { $0.id == tab.id }) {
                    state.tabs[tabIndex].htmlMetadata = htmlMetadata
                }

                return .none

            case let .arOverlay(.delegate(.setScene(tab: tab, scene: scene))):
                if let tabIndex = state.tabs.firstIndex(where: { $0.id == tab.id }) {
                    state.tabs[tabIndex].scene = scene
                }

                try? state.arContainer.sceneRenderer.drawScene(
                    scenes: state.scenes
                )

                return .none

            case .arOverlay:
                return .none

            case let .arContainer(.delegate(.setQRCode(qrCode))):
                state.arOverlay.qrCode = qrCode
                return .none

            case .arContainer:
                return .none

            case .onAppear:
                self.locationClient.start()
                return .none
            }
        }
    }
}
