//
//  WidgetSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/9.
//

import SwiftUI
import WidgetKit

struct WidgetSettingView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("setting.widget.background.title") {
                    WidgetBackgroundSettingView()
                }
            } header: {
                Text("setting.widget.appearance.header")
            }

            Section {
                Button("setting.widget.refresh.manually") {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } header: {
                Text("setting.widget.refresh.header")
            } footer: {
                Text("setting.widget.refresh.footer")
            }
        }
        .navigationTitle("setting.widget.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
