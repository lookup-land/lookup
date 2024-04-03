// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation
import Inject
@_exported import Playbook
@_exported import PlaybookUI
import SharedModels
import SharedViews
import SwiftUI

public enum AppScenarios {
    public static func build() -> Playbook {
        let appPlaybook = Playbook()

        appPlaybook.addScenarios(of: "Fonts") {
            Scenario("Default", layout: .fill) {
                VStack(spacing: 8.0) {
                    Text("Large Title").style(.largeTitle)
                    Text("Title").style(.title)
                    Text("Headline").style(.headline)
                    Text("Body").style(.body)
                    Text("Callout").style(.callout)
                    Text("Subheadline").style(.subheadline)
                    Text("Footnote").style(.footnote)
                    Text("Caption").style(.caption)
                }
            }
        }

        return appPlaybook
    }
}
