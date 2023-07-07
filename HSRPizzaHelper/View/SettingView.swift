//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import Mantis
import SwifterSwift
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
                    NavigationLink {
                        NotificationSettingView()
                    } label: {
                        Label {
                            Text("setting.notification.title")
                        } icon: {
                            Image(systemSymbol: .bellBadgeFill)
                        }
                    }
                }
                Section {
                    Button {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    } label: {
                        Label("sys.label.rate", systemSymbol: .starBubble)
                    }
                    NavigationLink(
                        destination: GlobalDonateView()
                    ) {
                        Label("sys.label.support", systemSymbol: .giftcard)
                    }
                    NavigationLink(destination: ContactInfoView()) {
                        Label("sys.label.contact", systemSymbol: .bubbleLeftAndBubbleRight)
                    }
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
                        } icon: {
                            Image(systemSymbol: .globe)
                        }
                    }

                    let url: String = {
                        switch AppConfig.appLanguage {
                        case .en:
                            return "https://hsr.ophelper.top/static/faq_en"
                        case .zhcn, .zhtw:
                            return "https://hsr.ophelper.top/static/faq"
                        case .ja:
                            return "https://hsr.ophelper.top/static/faq_ja"
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
            .listStyle(.insetGrouped)
            .navigationTitle("settings.title")
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                ManageAccountsView()
            }
            #endif
        }
        .navigationViewStyle(.columns)
    }
}

// MARK: - OtherSettingsView

private struct OtherSettingsView: View {
    // MARK: Internal

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
                Menu {
                    Link(destination: URL(string: "https://user.mihoyo.com/")!) {
                        Text("sys.server.cn")
                    }
                    Link(destination: URL(string: "https://account.hoyoverse.com/")!) {
                        Text("sys.server.os")
                    }
                } label: {
                    Text("sys.manage_hoyolab_account")
                }
            } footer: {
                Text("sys.manage_hoyolab_account.footer")
                    .textCase(.none)
            }

            Section {
                Button("sys.account.force_push") {
                    var accountInfo = "sys.account.force_push.received".localized()
                    for account in accounts {
                        accountInfo += "\(String(describing: account.name!)) (\(String(describing: account.uid!)))\n"
                    }
                    for account in accounts {
                        WatchConnectivityManager.shared.sendAccounts(account, accountInfo)
                    }
                }
            } footer: {
                Text("sys.account.force_push.footer")
                    .textCase(.none)
            }

            Section {
                NavigationLink("app.userpolicy.title") {
                    let url: String = {
                        switch AppConfig.appLanguage {
                        case .en:
                            return "https://hsr.ophelper.top/static/policy_en"
                        case .zhcn, .zhtw:
                            return "https://hsr.ophelper.top/static/policy"
                        case .ja:
                            return "https://hsr.ophelper.top/static/policy_ja"
                        }
                    }()
                    WebBrowserView(url: url)
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

    // MARK: Private

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}
