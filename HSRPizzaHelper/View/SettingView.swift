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
                    let url: String = {
                        switch Bundle.main.preferredLocalizations.first {
                        case "zh-Hans", "zh-Hant", "zh-HK":
                            return "https://hsr.ophelper.top/static/faq.html"
                        default:
                            return "https://hsr.ophelper.top/static/faq_en.html"
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
            Section {
                VStack(alignment: .leading) {
                    Text("sys.about.otherapp.title")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Link(destination: URL(string: "https://apps.apple.com/cn/app/id1635319193")!) {
                        HStack {
                            Image("ophelper.icon")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            Text("ophelper.name")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemSymbol: .chevronForward)
                        }
                    }
                }
            }
        }
        .navigationTitle("sys.more.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
