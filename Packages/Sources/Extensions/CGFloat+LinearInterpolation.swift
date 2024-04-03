// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation

public extension CGFloat {
    static func linearInterpolation(
        start: CGFloat,
        end: CGFloat,
        progress: CGFloat
    ) -> CGFloat {
        return start + (end - start) * progress
    }
}
