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

    @StateObject var storeManager: StoreManager

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
            SettingView(storeManager: storeManager)
                .tag(1)
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
