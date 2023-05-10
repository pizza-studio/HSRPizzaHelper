//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import Mantis
import SwiftUI

// MARK: - SettingView

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        ManageAccountsView()
                    } label: {
                        Label("account.manage.title", systemSymbol: .personFill)
                    }
                }
                Section {
                    NavigationLink {
                        WidgetSettingView()
                    } label: {
                        Label("setting.widget.title", systemSymbol: .platter2FilledIphone)
                    }
                }
                Section {
                    Button {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    } label: {
                        Label("sys.label.rate", systemSymbol: .starBubble)
                    }
                    // TODO: support us
//                    NavigationLink(
//                        destination: GlobalDonateView(
//                            storeManager: storeManager
//                        )
//                    ) {
                    Label("sys.label.support", systemSymbol: .giftcard)
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
                    NavigationLink {
                        OtherSettingsView()
                    } label: {
                        Label("sys.more.title", systemSymbol: .ellipsis)
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
                NavigationLink("update.history.title") {
                    HistoryVersionInfoView()
                }
            }

            Section {
                Link(destination: URL(string: "https://apps.apple.com/cn/app/id1635319193")!) {
                    HStack {
                        Image("icon.ophelper")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        VStack(alignment: .leading) {
                            Text("ophelper.name")
                                .foregroundColor(.primary)
                            Text("ophelper.intro")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                        Image(systemSymbol: .chevronForward)
                    }
                }
            } header: {
                Text("sys.about.otherapp.title")
            }
            Section {
                Link(destination: URL(string: "https://github.com/pizza-studio/hsrpizzahelper")!) {
                    Label {
                        Text("sys.about.opensource.title")
                    } icon: {
                        Image("icon.github")
                            .resizable()
                            .scaledToFit()
                    }
                }
            } footer: {
                Text("sys.about.opensource.footer")
            }

            Section {
                NavigationLink("app.userpolicy.title") {
                    WebBrowserView(url: "https://hsr.ophelper.top/static/policy")
                        .navigationTitle("app.userpolicy.title")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("sys.about.title") {
                    AboutView()
                }
            }
        }
        .navigationTitle("sys.more.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
