// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public enum LayersEntityType: String, Codable, Equatable {
    case anchor
    case box
    case model
    case text
}

public protocol LayersEntity: LayersBaseObject {
    var type: LayersEntityType { get set }
    var children: [any LayersEntity] { get set }
    var transform: LayersTransform? { get set }
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
    func decodeEntity(forKey key: K) throws -> any LayersEntity {
        let innerContainer = self

        let dynamicContainer = try innerContainer.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)

        let type = try dynamicContainer.decode(LayersEntityType.self, forKey: .init(stringValue: "type"))

        switch type {
        case .anchor:
            return try self.decode(LayersAnchor.self, forKey: key)
        case .box:
            return try innerContainer.decode(LayersBox.self, forKey: key)
        case .model:
            return try self.decode(LayersModel.self, forKey: key)
        case .text:
            return try self.decode(LayersText.self, forKey: key)
        }
    }

    func decodeEntities(forKey key: K) throws -> [any LayersEntity] {
        var entities = [any LayersEntity]()

        var nestedContainer = try self.nestedUnkeyedContainer(forKey: key)

        while !nestedContainer.isAtEnd {
            var innerContainer = nestedContainer

            let dynamicContainer = try innerContainer.nestedContainer(keyedBy: DynamicCodingKeys.self)

            let type = try dynamicContainer.decode(LayersEntityType.self, forKey: DynamicCodingKeys(stringValue: "type"))

            switch type {
            case .anchor:
                try entities.append(
                    nestedContainer.decode(LayersAnchor.self)
                )
            case .box:
                try entities.append(
                    nestedContainer.decode(LayersBox.self)
                )
            case .model:
                try entities.append(
                    nestedContainer.decode(LayersModel.self)
                )
            case .text:
                try entities.append(
                    nestedContainer.decode(LayersText.self)
                )
            }
        }

        return entities
    }
}
