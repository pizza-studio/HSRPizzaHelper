//
//  WidgetErrorView.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/6/11.
//

import SwiftUI

// MARK: - WidgetErrorView

struct WidgetErrorView: View {
    let error: Error

    var body: some View {
        VStack(alignment: .leading) {
            Text(error.localizedDescription)
                .font(.footnote)
            if let localizedError = error as? LocalizedError,
               let recoverySuggestion = localizedError.recoverySuggestion {
                Text(recoverySuggestion)
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .accessibilityBackground(enable: true)
        .embed(in: .bottomLeft)
    }
}

// MARK: - AccessibilityBackground

private struct AccessibilityBackground: ViewModifier {
    let enable: Bool

    func body(content: Content) -> some View {
        if enable {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
        } else {
            content
        }
    }
}

extension View {
    fileprivate func accessibilityBackground(enable: Bool) -> some View {
        modifier(AccessibilityBackground(enable: enable))
    }
}
