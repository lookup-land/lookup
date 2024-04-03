// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public struct LayersTextFont: Codable {
    public var name: String
    public var size: Float
}

public enum LayersTextAlignment: String, Codable {
    case center
}

public enum LayersTextLineBreakMode: String, Codable {
    case byWordWrapping = "by-word-wrapping"
}

public struct LayersText: LayersEntity {
    public var id: UUID
    public var type = LayersEntityType.text
    public var children: [any LayersEntity]
    public var transform: LayersTransform?
    public var text: String
    public var extrusionDepth: Float
    public var font: LayersTextFont
    public var alignment: LayersTextAlignment
    public var lineBreakMode: LayersTextLineBreakMode

    public static func == (lhs: LayersText, rhs: LayersText) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, children, transform, text, extrusionDepth, font, alignment, lineBreakMode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = .box
        self.children = try container.decodeEntities(forKey: .children)
        self.transform = try container.decodeIfPresent(LayersTransform.self, forKey: .transform)
        self.text = try container.decode(String.self, forKey: .text)
        self.extrusionDepth = try container.decode(Float.self, forKey: .extrusionDepth)
        self.font = try container.decode(LayersTextFont.self, forKey: .font)
        self.alignment = try container.decode(LayersTextAlignment.self, forKey: .alignment)
        self.lineBreakMode = try container.decode(LayersTextLineBreakMode.self, forKey: .lineBreakMode)
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
        try container.encode(self.text, forKey: .text)
        try container.encode(self.extrusionDepth, forKey: .extrusionDepth)
        try container.encode(self.font, forKey: .font)
        try container.encode(self.alignment, forKey: .alignment)
        try container.encode(self.lineBreakMode, forKey: .lineBreakMode)
    }
}
