//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - SettingView

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("account.manage.title") {
                        ManageAccountsView()
                    }
                }
                if #available(iOS 16, *) {
                    Section {
                        NavigationLink("setting.widgetbackground.title") {
                            WidgetBackgroundSettingView()
                        }
                    }
                }
                Section {
                    Button("sys.label.rate") {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    }
                    // TODO: support us
//                    NavigationLink(
//                        destination: GlobalDonateView(
//                            storeManager: storeManager
//                        )
//                    ) {
                    Text("sys.label.support")
//                    }
                }
                Section {
                    Button {
                        UIApplication.shared
                            .open(URL(
                                string: UIApplication
                                    .openSettingsURLString
                            )!)
                    } label: {
                        Label {
                            Text("sys.label.preferredlang")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemSymbol: .globe)
                        }
                    }
                    // TODO: replace to HSR version
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
                            .navigationTitle("sys.faq.title")
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

// MARK: - OtherSettingsView

private struct OtherSettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("sys.about.title") {
                    AboutView()
                }
            }
        }
        .navigationTitle("sys.more.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
