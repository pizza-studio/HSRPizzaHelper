//
//  WidgetSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/9.
//

import SwiftUI

struct WidgetSettingView: View {
    var body: some View {
        List {
            Section {
                if #available(iOS 16, *) {
                    NavigationLink("setting.widget.background.title") {
                        WidgetBackgroundSettingView()
                    }
                }
            } header: {
                Text("setting.widget.appearance.header")
            }

            Section {
                WidgetFrequencyEditor()
            } header: {
                Text("setting.widget.refresh.header")
            }
        }
        .navigationTitle("setting.widget.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
