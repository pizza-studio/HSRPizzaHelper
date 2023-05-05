//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import SFSafeSymbols
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
            SettingView()
                .tabItem {
                    Label("tab.settings", systemSymbol: .gear)
                }
        }
    }
}
