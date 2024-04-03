// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import AppModule
import ComposableArchitecture
import SwiftUI

@main
struct LookupApp: App {
    var store: StoreOf<AppReducer>

    init() {
        self.store = Store(
            initialState: AppReducer.State()
        ) {
            AppReducer()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .dynamicTypeSize(.large ... .accessibility5)
                .statusBar(hidden: true)
        }
    }
}
