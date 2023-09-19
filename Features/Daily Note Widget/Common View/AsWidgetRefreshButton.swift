//
//  AsWidgetRefreshButton.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/9/18.
//

import Foundation
import SwiftUI

extension View {
    func asWidgetRefreshButton() -> some View {
        modifier(AsWidgetRefreshButton())
    }
}

// MARK: - AsWidgetRefreshButton

private struct AsWidgetRefreshButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, iOSApplicationExtension 17.0, *) {
            Button(intent: GeneralWidgetRefreshIntent()) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}
