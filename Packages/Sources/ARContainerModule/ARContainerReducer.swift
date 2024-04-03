// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ARKit
import ComposableArchitecture
import Foundation
import RealityKit
import SharedModels
import SharedViews
import Vision
import WebKit

@Reducer
public struct ARContainerReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var arView: ARView
        public var tabs: IdentifiedArrayOf<Tab>
        public var qrCodes: [QRCode]
        public var sceneRenderer: SceneRenderer

        public init() {
            let arView = ARView(frame: .zero)

            self.arView = arView
            self.tabs = []
            self.qrCodes = []
            self.sceneRenderer = SceneRenderer(
                arView: arView
            )
        }
    }

    public enum Action {
        case delegate(Delegate)
        case onDetectQRCode(VNBarcodeObservation)
    }

    public enum Delegate: Equatable {
        case setQRCode(QRCode)
    }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case let .onDetectQRCode(qrCode):
                state.qrCodes.append(QRCode(data: qrCode, date: .now))

                state.qrCodes = state.qrCodes
                    .filter { $0.date.timeIntervalSinceNow > -1 }
                    .sorted {
                        let aSize = $0.data.boundingBox.size
                        let bSize = $1.data.boundingBox.size

                        let aArea = aSize.width * aSize.height
                        let bArea = bSize.width * bSize.height
                        return aArea > bArea
                    }

                if let qrCode = state.qrCodes.first {
                    return
                        .send(.delegate(.setQRCode(qrCode)))
                }

                return .none
            }
        }
    }
}
