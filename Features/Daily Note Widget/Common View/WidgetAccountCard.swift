//
//  WidgetAccountCard.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/8.
//

import SFSafeSymbols
import SwiftUI

// MARK: - WidgetAccountCard

struct WidgetAccountCard: View {
    let accountName: String?

    let useAccessibilityBackground: Bool

    var body: some View {
        if let accountName = accountName {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemSymbol: .personFill)
                Text(accountName)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .accessibilityBackground(enable: useAccessibilityBackground)
        }
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
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
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
