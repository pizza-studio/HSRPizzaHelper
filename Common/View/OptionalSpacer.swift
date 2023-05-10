//
//  OptionalSpacer.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import SwiftUI

/// A View that provides an optional Spacer based on an enable flag.
struct OptionalSpacer: View {
    // MARK: Lifecycle

    /**
     Spacer with the specified enable flag.

     - Parameter enable: A boolean flag that specifies whether to add a spacer or not.
     - Parameter minLength: An optional minimum length for the spacer.
     */
    init(_ enable: Bool, minLength: CGFloat? = nil) {
        self.enable = enable
        self.minLength = minLength
    }

    // MARK: Internal

    var body: some View {
        if enable {
            Spacer(minLength: minLength)
        } else {
            EmptyView()
        }
    }

    // MARK: Private

    private let enable: Bool
    private var minLength: CGFloat?
}
