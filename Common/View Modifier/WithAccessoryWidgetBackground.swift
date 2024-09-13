//
//  WithAccessoryWidgetBackground.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2024/9/13.
//

import Foundation
import SwiftUI
import WidgetKit

extension View {
    func withAccessoryWidgetBackground()
        -> some View {
        modifier(WithAccessoryWidgetBackground())
    }
}

// MARK: - WithAccessoryWidgetBackground

private struct WithAccessoryWidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17, iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) {
                AccessoryWidgetBackground()
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                content
            }
        }
    }
}
