// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Foundation
import UIKit

public extension UIScrollView {
    var isBouncing: Bool {
        let isBouncingTop = self.contentOffset.y <= -self.contentInset.top

        let isBouncingBottom = self.contentOffset.y >= (self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)

        return isBouncingTop || isBouncingBottom
    }

    var isScrollable: Bool {
        return self.contentSize.height > self.bounds.size.height
    }
}
