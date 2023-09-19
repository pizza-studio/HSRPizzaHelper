//
//  ContainerBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/9/18.
//

import Foundation
import SwiftUI

extension View {
    func myWidgetContainerBackground<V: View>(
        withPadding padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(padding: padding, background: content))
    }
}

// MARK: - ContainerBackgroundModifier

private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let padding: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.containerBackground(for: .widget) {
                background()
            }
        } else {
            content
                .padding(padding)
                .background {
                    background()
                }
        }
    }
}
