// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public struct LayersBox: LayersEntity {
    public var id: UUID
    public var type = LayersEntityType.box
    public var children: [any LayersEntity]
    public var transform: LayersTransform?
    public var size: Float
    public var cornerRadius: Float

    public static func == (lhs: LayersBox, rhs: LayersBox) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, children, transform, size, cornerRadius
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = .box
        self.children = try container.decodeEntities(forKey: .children)
        self.transform = try container.decodeIfPresent(LayersTransform.self, forKey: .transform)
        self.size = try container.decode(Float.self, forKey: .size)
        self.cornerRadius = try container.decode(Float.self, forKey: .cornerRadius)
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
        try container.encode(self.size, forKey: .size)
        try container.encode(self.cornerRadius, forKey: .cornerRadius)
    }
}
