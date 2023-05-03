//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SwiftUI
import HBMihoyoAPI

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Manage Account") {
                    ManageAccountsView()
                }
            }
            .navigationTitle("Setting")
        }
    }
}

