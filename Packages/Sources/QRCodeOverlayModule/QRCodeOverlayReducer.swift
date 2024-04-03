// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct QRCodeOverlayReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var qrCode: QRCode?

        public var currentDate = Date.now
        public var prevPressDate = Date.distantPast

        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case onPress
        case onExpired
        case onTimer(Date)
    }

    public enum Delegate: Equatable {
        case onPress
        case onExpired
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case .onPress:
                state.prevPressDate = Date.now
                return .send(.delegate(.onPress))

            case .onExpired:
                return .send(.delegate(.onExpired))

            case let .onTimer(input):
                state.currentDate = input

                if let qrCode = state.qrCode,
                   qrCode.date.timeIntervalSince(state.currentDate) < -1
                {
                    return .send(.onExpired)
                }

                return .none
            }
        }
    }
}
