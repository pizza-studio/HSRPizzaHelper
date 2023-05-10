//
//  OptionalSpacer.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import SwiftUI

struct OptionalSpacer: View {
    // MARK: Lifecycle

    init(_ enable: Bool, minLength: CGFloat? = nil) {
        self.enable = enable
        self.minLength = minLength
    }

    // MARK: Internal

    let enable: Bool
    var minLength: CGFloat?

    var body: some View {
        if enable {
            Spacer(minLength: minLength)
        }
    }
}
