// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public enum LayersEventMessageType: String, Codable {
    case startScene = "scene.start"
    case updateScene = "scene.update"
    case hideBrowser = "browser.hide"
    case initialize
}

public enum LayersEventMessageData: Codable {
    case startScene(LayersScene)
    case updateScene(LayersScene)
    case hideBrowser
    case initialize
}

public struct EventMessage: Codable {
    public var type: LayersEventMessageType
    public var data: LayersEventMessageData

    enum CodingKeys: String, CodingKey {
        case type, data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(LayersEventMessageType.self, forKey: .type)

        switch self.type {
        case .startScene:
            self.data = .startScene(try container.decode(LayersScene.self, forKey: .data))
        case .updateScene:
            self.data = .updateScene(try container.decode(LayersScene.self, forKey: .data))
        case .hideBrowser:
            self.data = .hideBrowser
        case .initialize:
            self.data = .initialize
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.type.rawValue, forKey: .type)
        try container.encode(self.data, forKey: .data)
    }
}
