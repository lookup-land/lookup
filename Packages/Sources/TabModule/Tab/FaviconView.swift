// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Inject
import SharedModels
import SwiftUI

struct FaviconView: View {
    @ObserveInjection private var iO

    let htmlMetadata: HTMLMetadata?

    var body: some View {
        AsyncImage(
            url: htmlMetadata?.favicon.url,
            transaction: Transaction(animation: .smooth)
        ) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .transition(.opacity)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .transition(.move(edge: .trailing))
            case .failure:
                Text(
                    String(htmlMetadata?.title?.first ?? "?")
                )
                .style(.body, weight: .bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                .cornerRadius(12)
            @unknown default:
                EmptyView()
            }
        }
        .enableInjection()
    }
}
