// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation
import Vision

public struct QRCode: Equatable {
    public var data: VNBarcodeObservation
    public var date: Date

    public init(data: VNBarcodeObservation, date: Date) {
        self.data = data
        self.date = date
    }
}
