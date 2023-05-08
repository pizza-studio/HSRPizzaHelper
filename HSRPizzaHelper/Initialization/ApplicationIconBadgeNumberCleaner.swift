//
//  ApplicationIconBadgeNumberCleaner.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Foundation
import SwiftUI

// MARK: - ApplicationIconBadgeNumberCleaner

private struct ApplicationIconBadgeNumberCleaner: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
    }
}

extension View {
    func cleanApplicationIconBadgeNumber() -> some View {
        modifier(ApplicationIconBadgeNumberCleaner())
    }
}
