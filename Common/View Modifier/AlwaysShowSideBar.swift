//
//  AlwaysShowSideBar.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/12/5.
//

import Foundation
import SwiftUI

// MARK: - AlwaysShowSideBar

private struct AlwaysShowSideBar: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.navigationSplitViewStyle(.balanced)
        } else {
            content.navigationViewStyle(.columns)
        }
    }
}

extension View {
    func alwaysShowSideBar() -> some View {
        modifier(AlwaysShowSideBar())
    }
}
