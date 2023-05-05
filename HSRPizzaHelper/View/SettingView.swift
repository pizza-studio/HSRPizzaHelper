//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("account.manage.title") {
                        ManageAccountsView()
                    }
                }
                Section {
                    NavigationLink("sys.more.title") {
                        OtherSettingsView()
                    }
                }
            }
            .navigationTitle("settings.title")
        }
    }
}

private struct OtherSettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("sys.about.title") {
                    AboutView()
                }
            }
        }
    }
}
