//
//  ScenePhaseOnChange.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Foundation
import SwiftUI

private struct OnAppBecomeActiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { scenePhase in
                if scenePhase == .active {
                    action()
                }
            }
    }
}

private struct OnAppEnterBackgroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { scenePhase in
                if scenePhase == .background {
                    action()
                }
            }
    }
}

private struct OnAppBecomeInactiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    let action: () -> Void

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
    func onAppBecomeActive(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppBecomeActiveModifier(action: action))
    }

    func onAppEnterBackground(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppEnterBackgroundModifier(action: action))
    }

    func onAppBecomeInactive(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppBecomeInactiveModifier(action: action))
    }
}
