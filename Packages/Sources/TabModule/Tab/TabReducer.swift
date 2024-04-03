// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct TabReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable, Equatable {
        public var tab: Tab

        public var isGestureStarted = false

        public var id: UUID {
            return tab.id
        }

        public init(
            tab: Tab,
            htmlMetadata: HTMLMetadata? = nil
        ) {
            self.tab = tab
        }
    }

    public enum Action {
        case delegate(Delegate)
        case onPress
        case onRemove
        case onToggleGesture(Bool)
    }

    public enum Delegate: Equatable {
        case toggleGesture(Bool)
        case selectTab(Tab)
        case removeTab(Tab)
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case let .onToggleGesture(value):
                return .send(.delegate(.toggleGesture(value)))

            case .onPress:
                return .send(.delegate(.selectTab(state.tab)))

            case .onRemove:
                return .send(.delegate(.removeTab(state.tab)))
            }
        }
    }
}
