// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WebKit

public struct Favicon: Equatable {
    public var url: URL

    public init(url: URL) {
        self.url = url
    }
}

public enum InitialBrowserVisibility: String {
    case visible
    case hidden
}

public struct HTMLMetadata: Equatable {
    public var favicon: Favicon
    public var title: String?
    public var themeColor: String?
    public var initialBrowserVisibility: InitialBrowserVisibility

    public init(
        favicon: Favicon,
        title: String? = nil,
        themeColor: String? = nil,
        initialBrowserVisibility: InitialBrowserVisibility = .visible
    ) {
        self.favicon = favicon
        self.title = title
        self.themeColor = themeColor
        self.initialBrowserVisibility = initialBrowserVisibility
    }
}

public struct Tab: Equatable, Identifiable {
    public var id: UUID
    public var webView: WKWebView
    public var htmlMetadata: HTMLMetadata?
    public var scene: LayersScene?
    public var layersEnabled: Bool

    public init(
        id: UUID = .init(),
        webView: WKWebView = WKWebView(),
        htmlMetadata: HTMLMetadata? = nil,
        scene: LayersScene? = nil,
        layersEnabled: Bool = false
    ) {
        self.id = id
        self.webView = webView
        self.htmlMetadata = htmlMetadata
        self.scene = scene
        self.layersEnabled = layersEnabled
    }
}
