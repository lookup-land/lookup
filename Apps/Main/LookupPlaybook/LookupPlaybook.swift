// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Inject
import PlaybookModule
import PlaybookUI
import SwiftUI

@main
struct LookupPlaybook: App {
    @ObserveInjection private var iO

    var body: some Scene {
        WindowGroup {
            PlaybookCatalog(
                playbook: AppScenarios.build()
            )
            .id(UUID())
            .enableInjection()
        }
    }
}
