// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Combine
import ComposableArchitecture
import CoreLocation
import Foundation
import LocationClient
import SharedModels
import TabModule

@Reducer
public struct NavigatorReducer {
    @Dependency(\.locationClient) var locationClient

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var tabBar = TabBarReducer.State()

        public var tabs: IdentifiedArrayOf<Tab> = [] {
            didSet {
                tabBar.tabs = tabs
            }
        }

        public var isRemoveTabOverlayVisible = false

        public var selectedTab: Tab? {
            didSet {
                tabBar.selectedTab = selectedTab
            }
        }

        public var isBrowserVisible = false
        public var locality = ""
        public var heading: CLHeading?

        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case tabBar(TabBarReducer.Action)
        case setHeading(CLHeading)
        case setLocality(String)
        case onOpenBrowser

        case onAppear
    }

    public enum Delegate: Equatable {
        case openNewTab
        case removeTab(Tab)
        case selectTab(Tab)
        case openBrowser
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.tabBar, action: \.tabBar) {
            TabBarReducer()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case .tabBar(.delegate(.openNewTab)):
                return .send(.delegate(.openNewTab))

            case let .tabBar(.delegate(.toggleGesture(value))):
                state.isRemoveTabOverlayVisible = value
                return .none

            case let .tabBar(.delegate(.selectTab(tab))):
                return .send(.delegate(.selectTab(tab)))

            case let .tabBar(.delegate(.removeTab(tab))):
                return .send(.delegate(.removeTab(tab)))

            case .tabBar:
                return .none

            case let .setHeading(heading):
                state.heading = heading
                return .none

            case let .setLocality(locality):
                state.locality = locality
                return .none

            case .onOpenBrowser:
                return .send(.delegate(.openBrowser))

            case .onAppear:
                return .run { [] send in
                    Task {
                        for await heading in locationClient.headings {
                            await send(.setHeading(heading))
                        }
                    }

                    Task {
                        var isFetched = false

                        for await locations in locationClient.locations {
                            if isFetched {
                                continue
                            }

                            if let location = locations.first,
                               let locality = await self.locationClient.getLocality(
                                   location: location
                               )
                            {
                                await send(.setLocality(locality), animation: .smooth)
                                isFetched = true
                            }
                        }
                    }
                }
            }
        }
    }
}
