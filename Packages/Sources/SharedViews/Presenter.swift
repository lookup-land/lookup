// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

public struct Presenter<Item, Content>: View where Item: Identifiable, Content: View {
    @Binding var item: Item?
    let content: (Item) -> Content

    public init(
        item: Binding<Item?>,
        content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.content = content
    }

    public var body: some View {
        Group {
            if let item = item {
                content(item)
            }
        }
    }
}
