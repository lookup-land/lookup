// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import CoreLocation
import Inject
import SwiftUI

public struct CompassView: View {
    @ObserveInjection private var iO

    var heading: CLHeading?

    public init(heading: CLHeading?) {
        self.heading = heading
    }

    public var body: some View {
        VStack {
            Image("filled.arrow.compass")
                .resizable()
                .svgFill(color: .primary)
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(heading?.trueHeading ?? 0))
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 0)
        }
        .frame(width: 32, height: 32)
        .background(Color.treeGreen)
        .cornerRadius(12)
        .enableInjection()
    }
}
