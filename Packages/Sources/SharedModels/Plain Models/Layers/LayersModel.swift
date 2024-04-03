// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public struct LayersModel: LayersEntity {
    public var id: UUID
    public var type = LayersEntityType.model
    public var children: [any LayersEntity]
    public var transform: LayersTransform?
    public var mesh: any LayersEntity
    public var materials: [any LayersMaterial]

    public static func == (lhs: LayersModel, rhs: LayersModel) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, children, transform, mesh, materials
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = .box
        self.children = try container.decodeEntities(forKey: .children)
        self.transform = try container.decodeIfPresent(LayersTransform.self, forKey: .transform)
        self.mesh = try container.decodeEntity(forKey: .mesh)
        self.materials = try container.decodeMaterials(forKey: .materials)
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
        try container.encode(self.mesh, forKey: .mesh)

        var materialsContainer = container.nestedUnkeyedContainer(forKey: .materials)
        for material in self.materials {
            try materialsContainer.encode(material)
        }
    }
}
