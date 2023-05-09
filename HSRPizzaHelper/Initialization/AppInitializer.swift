//
//  AppInitializer.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Foundation
import SwiftUI

// MARK: - AppInitializer

private struct AppInitializer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .checkAndPopPolicySheet()
            .cleanApplicationIconBadgeNumber()
            .checkAndPopLatestVersionSheet()
            .checkAndReloadWidgetTimeline()
    }
}

extension View {
    func initializeApp() -> some View {
        modifier(AppInitializer())
    }
}
