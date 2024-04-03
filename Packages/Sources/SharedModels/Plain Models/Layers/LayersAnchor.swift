// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public struct LayersAnchor: LayersEntity {
    public var id: UUID
    public var type = LayersEntityType.anchor
    public var children: [any LayersEntity]
    public var transform: LayersTransform?
    public var position: LayersPosition

    public static func == (lhs: LayersAnchor, rhs: LayersAnchor) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, children, transform, position
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = .anchor
        self.children = try container.decodeEntities(forKey: .children)
        self.transform = try container.decodeIfPresent(LayersTransform.self, forKey: .transform)
        self.position = try container.decode(LayersPosition.self, forKey: .position)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)

        var childrenContainer = container.nestedUnkeyedContainer(forKey: .children)
        for child in self.children {
            try childrenContainer.encode(child)
        }

        try container.encodeIfPresent(self.transform, forKey: .transform)
        try container.encode(self.position, forKey: .position)
    }
}
