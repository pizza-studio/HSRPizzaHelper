//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import Defaults
import DefaultsKeys
import HBPizzaHelperAPI
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    // MARK: Internal

    var body: some View {
        TabView(selection: index) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
                .toolbarBackground(.thinMaterial, for: .tabBar)
            DetailPortalView()
                .tag(1)
                .tabItem {
                    Label("tab.detailPortal", systemSymbol: .personTextRectangle)
                }
                .toolbarBackground(.thinMaterial, for: .tabBar)
            ToolView()
                .tag(2)
                .tabItem {
                    Label("tab.tool", systemSymbol: .shippingboxFill)
                }
            SettingView()
                .tag(3)
                .tabItem {
                    Label("tab.settings", systemSymbol: .gear)
                }
        }
        .tint(tintForCurrentTab)
        .onChange(of: selection) { _ in
            feedbackGenerator.selectionChanged()
        }
        .initializeApp()
    }

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            selection = $0
            Defaults[.appTabIndex] = $0
            UserDefaults.hsrSuite.synchronize()
        }
    ) }

    // MARK: Private

    @State private var selection: Int = {
        guard Defaults[.restoreTabOnLaunching] else { return 0 }
        guard (0 ..< 3).contains(Defaults[.appTabIndex]) else { return 0 }
        return Defaults[.appTabIndex]
    }()

    @Environment(\.colorScheme) private var colorScheme

    private let feedbackGenerator = UISelectionFeedbackGenerator()

    private var tintForCurrentTab: Color {
        switch selection {
        case 0, 1: return .accessibilityAccent(colorScheme)
        default: return .accentColor
        }
    }
}
