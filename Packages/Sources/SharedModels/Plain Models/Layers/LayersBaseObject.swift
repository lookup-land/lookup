// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public protocol LayersBaseObject: Codable, Equatable {
    var id: UUID { get set }
}

public extension LayersBaseObject {
    static func == (lhs: any LayersBaseObject, rhs: any LayersBaseObject) -> Bool {
        lhs.id == rhs.id
    }
}
