//
//  ScenePhaseOnChange.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Foundation
import SwiftUI

// MARK: - OnAppBecomeActiveModifier

/// A ViewModifier that adds an action to be performed whenever an app comes to active state.
private struct OnAppBecomeActiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on becoming active.
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

/// A ViewModifier that adds an action to be performed whenever an app enters background state.
private struct OnAppEnterBackgroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on entering the background state.
    let action: () -> ()

    /// The view body with the added action.
    /// - Parameter content: The Content view.
    /// - Returns: A view with the added action.
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

/// A ViewModifier that adds an action to be performed whenever an app becomes inactive.
private struct OnAppBecomeInactiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on becoming inactive.
    let action: () -> ()

    /// The view body with the added action.
    /// - Parameter content: The Content view.
    /// - Returns: A view with the added action.
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
    /// Add an action to be performed whenever an app comes to active state.
    ///
    /// - Parameter action: A closure that holds the action to be performed on becoming active.
    /// - Returns: A View with the added action.
    func onAppBecomeActive(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppBecomeActiveModifier(action: action))
    }

    /// Add an action to be performed whenever an app enters background state.
    ///
    /// - Parameter action: A closure that holds the action to be performed on entering the background state.
    /// - Returns: A View with the added action.
    func onAppEnterBackground(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppEnterBackgroundModifier(action: action))
    }

    /// Add an action to be performed whenever an app becomes inactive.
    ///
    /// - Parameter action: A closure that holds the action to be performed on becoming inactive.
    /// - Returns: A View with the added action.
    func onAppBecomeInactive(perform action: @escaping () -> ()) -> some View {
        modifier(OnAppBecomeInactiveModifier(action: action))
    }
}
