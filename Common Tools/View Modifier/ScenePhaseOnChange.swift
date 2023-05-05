//
//  ScenePhaseOnChange.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Foundation
import SwiftUI

// MARK: - OnAppBecomeActiveModifier

private struct OnAppBecomeActiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> ()

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { scenePhase in
                if scenePhase == .active {
                    action()
                }
            }
    }
}

// MARK: - OnAppEnterBackgroundModifier

private struct OnAppEnterBackgroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> ()

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { scenePhase in
                if scenePhase == .background {
                    action()
                }
            }
    }
}

// MARK: - OnAppBecomeInactiveModifier

private struct OnAppBecomeInactiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> ()

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { scenePhase in
                if scenePhase == .inactive {
                    action()
                }
            }
    }
}

extension View {
    func onAppBecomeActive(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppBecomeActiveModifier(action: action))
    }

    func onAppEnterBackground(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppEnterBackgroundModifier(action: action))
    }

    func onAppBecomeInactive(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppBecomeInactiveModifier(action: action))
    }
}
