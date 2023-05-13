//
//  InlineNavigationTitle.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import SwiftUI

extension View {
    func inlineNavigationTitle(_ title: LocalizedStringKey) -> some View {
        modifier(InlineNavigationTitle(title: title))
    }
}

// MARK: - InlineNavigationTitle

struct InlineNavigationTitle: ViewModifier {
    let title: LocalizedStringKey

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
