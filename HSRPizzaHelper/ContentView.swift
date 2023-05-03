//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SFSafeSymbols
import SwiftUI
import CoreData


struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemSymbol: .listBullet)
                }
            SettingView()
                .tabItem {
                    Label("Setting", systemSymbol: .gear)
                }
        }
    }
}
