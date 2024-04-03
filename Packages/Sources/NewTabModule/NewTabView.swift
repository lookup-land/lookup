// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SharedModels
import SharedViews
import SwiftUI

public struct NewTabView: View {
    @ObserveInjection private var iO

    @Bindable var store: StoreOf<NewTabReducer>

    @FocusState var isFocused: Bool

    public init(store: StoreOf<NewTabReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            TextField(
                "Search",
                text: $store.query.sending(\.setQuery)
            )
            .focused($isFocused)
            .font(
                Font.custom(
                    FontWeight.medium.rawValue,
                    size: FontSize.body.rawValue
                )
            )
            .keyboardType(.webSearch)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(12)
            .background(BlurBackground())
            .cornerRadius(12)
            .submitLabel(.go)
            .onSubmit {
                store.send(.onSubmit, animation: .smooth)
            }
            .padding([.bottom, .horizontal], 16)
        }
        .onAppear {
            isFocused = true
        }
        .enableInjection()
    }
}
