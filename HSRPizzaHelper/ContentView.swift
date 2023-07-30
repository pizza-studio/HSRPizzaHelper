//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import HBPizzaHelperAPI
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    // MARK: Internal

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
            ToolView()
                .tag(1)
                .tabItem {
                    Label("tab.tool", systemSymbol: .shippingboxFill)
                }
            SettingView()
                .tag(2)
                .tabItem {
                    Label("tab.settings", systemSymbol: .gear)
                }
        }
        .onChange(of: selection) { _ in
            feedbackGenerator.selectionChanged()
        }
        .initializeApp()
    }

    // MARK: Private

    @State private var selection: Int = 0

    private let feedbackGenerator = UISelectionFeedbackGenerator()
}
