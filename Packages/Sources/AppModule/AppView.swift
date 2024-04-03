// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ARContainerModule
import AROverlayModule
import ComposableArchitecture
import Inject
import LifetimeTracker
import SharedModels
import SharedViews
import SwiftUI

public struct AppView: View {
    @ObserveInjection private var iO

    var store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        #if DEBUG
        LifetimeTracker.setup(
            onUpdate: LifetimeTrackerDashboardIntegration(
                visibility: .visibleWithIssuesDetected,
                style: .circular
            ).refreshUI
        )
        #endif

        self.store = store
    }

    public var body: some View {
        ZStack {
            ARContainerView(
                store: store.scope(
                    state: \.arContainer,
                    action: \.arContainer
                )
            )
            .ignoresSafeArea()

            AROverlayView(
                store: store.scope(
                    state: \.arOverlay,
                    action: \.arOverlay
                )
            )
        }
        .task {
            store.send(.onAppear)
        }
        .background(.black)
        .enableInjection()
    }
}
