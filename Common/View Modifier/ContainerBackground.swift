//
//  ContainerBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/9/18.
//

import Foundation
import SwiftUI

extension View {
    func widgetContainerBackground<V: View>(
        withPaddingUnderIOS17 padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(paddingUnderIOS17: padding, background: content))
    }

    @available(iOS 17.0, iOSApplicationExtension 17.0, *)
    fileprivate func containerBackgroundStandbyDetector<V: View>(@ViewBuilder _ content: @escaping () -> V)
        -> some View {
        modifier(ContainerBackgroundStandbyDetector(background: content))
    }
}

// MARK: - ContainerBackgroundModifier

private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let paddingUnderIOS17: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        if #available(iOS 17, iOSApplicationExtension 17.0, *) {
            content.containerBackgroundStandbyDetector(background)
        } else {
            content
                .padding(paddingUnderIOS17)
                .background {
                    background()
                }
        }
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(iOSApplicationExtension 17.0, iOS 17.0, *)
private struct ContainerBackgroundStandbyDetector<V: View>: ViewModifier {
    @Environment(\.widgetContentMargins) var widgetContentMargins: EdgeInsets

    let background: () -> V

    func body(content: Content) -> some View {
        if widgetContentMargins.top < 5 {
            content
                .padding(7)
                .containerBackground(for: .widget) {
                    background()
                }
        } else {
            content.containerBackground(for: .widget) {
                background()
            }
        }
    }
}
