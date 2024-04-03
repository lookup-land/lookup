// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Extensions
import Foundation
import SharedModels

@Reducer
public struct NewTabReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var tab: Tab
        public var query: String

        public init(tab: Tab, query: String = "") {
            self.tab = tab
            self.query = query
        }
    }

    public enum Action {
        case delegate(Delegate)
        case onCancel
        case onSubmit
        case setQuery(String)

        public enum Delegate: Equatable {
            case cancel
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case .onCancel:
                return .send(.delegate(.cancel))

            case .onSubmit:
                return .none

            case let .setQuery(query):
                state.query = query
                return .none
            }
        }
    }
}
