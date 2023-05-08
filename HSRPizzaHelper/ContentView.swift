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
    var body: some View {
        TabView {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
            SettingView()
                .tag(1)
                .tabItem {
                    Label("tab.settings", systemSymbol: .gear)
                }
        }
        .initializeApp()
    }
}
