// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import Inject
import SwiftUI

#if targetEnvironment(simulator)
public struct ARContainerView: View {
    @ObserveInjection private var iO

    var store: StoreOf<ARContainerReducer>

    public init(store: StoreOf<ARContainerReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Image("mock-ar-view")
                .resizable()
        }
        .enableInjection()
    }
}
#endif
