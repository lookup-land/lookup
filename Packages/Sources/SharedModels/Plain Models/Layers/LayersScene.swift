// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public struct LayersScene: Codable, Equatable {
    public var anchors: [LayersAnchor]

    public static func == (lhs: LayersScene, rhs: LayersScene) -> Bool {
        lhs.anchors.map { $0.id } == rhs.anchors.map { $0.id }
    }

    enum CodingKeys: String, CodingKey {
        case anchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.anchors = try container.decode([LayersAnchor].self, forKey: .anchors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.anchors, forKey: .anchors)
    }
}
