//
//  OnFocused.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import SwiftUI

extension View {
    func onFocused(_ action: @escaping () -> Void) -> some View {
        modifier(OnFocused(action: action))
    }
}

// MARK: - OnFocused

private struct OnFocused: ViewModifier {
    @FocusState private var focus: Bool

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .focused($focus)
            .onChange(of: focus) { newValue in
                if newValue == true {
                    action()
                }
            }
    }
}
