// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public enum LayersMaterialType: String, Codable, Equatable {
    case simple
}

public protocol LayersMaterial: LayersBaseObject {
    var type: LayersMaterialType { get set }
}

public struct LayersSimpleMaterial: LayersMaterial {
    public var id: UUID
    public var type = LayersMaterialType.simple
    public var color: LayersRGBAColor
    public var roughness: Float
    public var metallic: Bool
}

private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}

extension KeyedDecodingContainer {
    func decodeMaterials(forKey key: K) throws -> [any LayersMaterial] {
        var materials = [any LayersMaterial]()

        var nestedContainer = try self.nestedUnkeyedContainer(forKey: key)

        while !nestedContainer.isAtEnd {
            var innerContainer = nestedContainer

            let dynamicContainer = try innerContainer.nestedContainer(keyedBy: DynamicCodingKeys.self)

            let type = try dynamicContainer.decode(LayersMaterialType.self, forKey: DynamicCodingKeys(stringValue: "type"))

            switch type {
            case .simple:
                try materials.append(nestedContainer.decode(LayersSimpleMaterial.self))
            }
        }

        return materials
    }
}
