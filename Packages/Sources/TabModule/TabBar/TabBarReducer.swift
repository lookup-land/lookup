// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct TabBarReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var tabReducers: IdentifiedArrayOf<TabReducer.State> = []

        public var tabs: IdentifiedArrayOf<Tab> = [] {
            didSet {
                tabReducers = IdentifiedArray(
                    uniqueElements: tabs.map { tab in
                        TabReducer.State(
                            tab: tab
                        )
                    }
                )
            }
        }

        public var selectedTab: Tab?

        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case tabReducers(IdentifiedActionOf<TabReducer>)
        case onNewTabPress
    }

    public enum Delegate: Equatable {
        case openNewTab
        case toggleGesture(Bool)
        case selectTab(Tab)
        case removeTab(Tab)
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            case .delegate:
                return .none

            case let .tabReducers(
                .element(
                    id: _,
                    action: .delegate(.toggleGesture(value))
                )
            ):
                return .send(.delegate(.toggleGesture(value)))

            case let .tabReducers(
                .element(
                    id: _,
                    action: .delegate(.selectTab(tab))
                )
            ):
                return .send(.delegate(.selectTab(tab)))

            case let .tabReducers(
                .element(
                    id: _,
                    action: .delegate(.removeTab(tab))
                )
            ):
                return .send(.delegate(.removeTab(tab)))

            case .tabReducers:
                return .none

            case .onNewTabPress:
                return .send(.delegate(.openNewTab))
            }
        }
        .forEach(\.tabReducers, action: \.tabReducers) {
            TabReducer()
        }
    }
}
