// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ARKit
import ComposableArchitecture
import RealityKit
import SwiftUI
import UIKit
import Vision

#if !targetEnvironment(simulator)
public struct ARContainerView: UIViewRepresentable {
    var store: StoreOf<ARContainerReducer>

    public init(store: StoreOf<ARContainerReducer>) {
        self.store = store
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public func makeUIView(context: Context) -> ARView {
        let arView = store.arView

        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = [.horizontal]

        arView.session.run(configuration)
        arView.session.delegate = context.coordinator

        return arView
    }

    public func updateUIView(_ uiView: ARView, context: Context) {}
}
#endif

public extension ARContainerView {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARContainerView

        private var isProcessingQRCode = false
        private var qrRequests = [VNRequest]()

        private var arView: ARView {
            parent.store.arView
        }

        init(_ parent: ARContainerView) {
            self.parent = parent
        }

        public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            startQrCodeDetection(frame: frame)
        }

        private func startQrCodeDetection(frame: ARFrame) {
            let request = VNDetectBarcodesRequest(completionHandler: handleQRCodeRequest)
            request.symbologies = [.qr]
            qrRequests = [request]

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.isProcessingQRCode {
                        return
                    }

                    self.isProcessingQRCode = true

                    let imageRequestHandler = VNImageRequestHandler(
                        cvPixelBuffer: frame.capturedImage,
                        options: [:]
                    )

                    try imageRequestHandler.perform(self.qrRequests)
                } catch {}
            }
        }

        private func handleQRCodeRequest(request: VNRequest, error: Error?) {
            if let results = request.results, let result = results.first as? VNBarcodeObservation {
                DispatchQueue.main.async {
                    self.parent.store.send(.onDetectQRCode(result), animation: .smooth)
                    self.isProcessingQRCode = false
                }
            } else {
                isProcessingQRCode = false
            }
        }
    }
}
