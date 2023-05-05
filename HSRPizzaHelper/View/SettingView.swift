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
                    let url: String = {
                        switch Bundle.main.preferredLocalizations.first {
                        case "zh-Hans", "zh-Hant", "zh-HK":
                            return "https://ophelper.top/static/faq.html"
                        default:
                            return "https://ophelper.top/static/faq_en.html"
                        }
                    }()
                    NavigationLink(
                        destination: WebBrowserView(url: url)
                            .navigationTitle("FAQ")
                            .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label("sys.faq.title", systemSymbol: .personFillQuestionmark)
                    }
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
