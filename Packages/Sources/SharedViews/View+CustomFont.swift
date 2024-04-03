// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

public enum FontWeight: String {
    case bold = "DMSans-Bold"
    case medium = "DMSans-Medium"
    case regular = "DMSans-Regular"
}

public enum FontSize: CGFloat {
    case largeTitle = 34
    case title = 28
    case headline = 24
    case body = 17
    case callout = 16
    case subheadline = 15
    case footnote = 13
    case caption = 12
}

public enum FontStyleType {
    case largeTitle
    case title
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption

    func size() -> FontSize {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption
        }
    }

    func weight() -> FontWeight {
        switch self {
        case .largeTitle: return .medium
        case .title: return .medium
        case .headline: return .medium
        case .body: return .medium
        case .callout: return .medium
        case .subheadline: return .medium
        case .footnote: return .medium
        case .caption: return .medium
        }
    }

    func relativeTo() -> Font.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption
        }
    }
}

public extension View {
    func style(
        _ font: FontStyleType,
        size: FontSize? = nil,
        weight: FontWeight? = nil,
        relativeTo: Font.TextStyle? = nil
    ) -> some View {
        let fontWeight = weight ?? font.weight()
        let fontSize = size ?? font.size()
        let fontRelativeTo = relativeTo ?? font.relativeTo()

        return style(fontWeight, fontSize, fontRelativeTo)
    }

    func style(_ font: FontWeight, _ size: FontSize,
               _ relativeTo: Font.TextStyle) -> some View
    {
        customFont(font.rawValue, size: size.rawValue, relativeTo: relativeTo)
    }

    func customFont(_ name: String, size: CGFloat,
                    relativeTo: Font.TextStyle) -> some View
    {
        font(.custom(name, size: size, relativeTo: relativeTo))
    }
}
