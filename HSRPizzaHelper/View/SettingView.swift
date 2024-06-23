//
//  SettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Defaults
import EnkaKitHSR
import HBMihoyoAPI
import SwifterSwift
import SwiftUI

// MARK: - SettingView

struct SettingView: View {
    // MARK: Public

    @ViewBuilder public var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $selectedView) {
                Section {
                    NavigationLink(value: Navigation.accountManagement) {
                        Label("account.manage.title", systemSymbol: .personFill)
                    }
                    NavigationLink(value: Navigation.theFAQ) {
                        Label("sys.faq.title", systemSymbol: .personFillQuestionmark)
                    }
                }

                Section {
                    NavigationLink(value: Navigation.notificationSettings) {
                        Label("setting.notification.title", systemSymbol: .bellBadgeFill)
                    }
                    NavigationLink(value: Navigation.widgetSettings) {
                        Label("setting.widget.title", systemSymbol: .platter2FilledIphone)
                    }
                    NavigationLink(value: Navigation.uiSettings) {
                        Label("setting.uirelated.title", systemSymbol: .pc)
                    }
                    Button {
                        callMUISettings()
                    } label: {
                        Label {
                            Text("sys.label.preferredlang")
                        } icon: {
                            Image(systemSymbol: .globe)
                        }
                    }
                }

                Section {
                    Button {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    } label: {
                        Label("sys.label.rate", systemSymbol: .starBubble)
                    }
                    NavigationLink(value: Navigation.donation) {
                        Label("sys.label.support", systemSymbol: .giftcard)
                    }
                    NavigationLink(value: Navigation.contact) {
                        Label("sys.label.contact", systemSymbol: .bubbleLeftAndBubbleRight)
                    }
                    NavigationLink(value: Navigation.moreSettings) {
                        Label("sys.more.title", systemSymbol: .ellipsis)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings.title")
        } detail: {
            navigationDetail(selection: $selectedView)
        }
        .alwaysShowSideBar()
    }

    // MARK: Internal

    enum Navigation {
        case accountManagement
        case theFAQ
        case widgetSettings
        case notificationSettings
        case uiSettings
        case donation
        case contact
        case moreSettings
    }

    // MARK: Private

    private static let faqURL: String = {
        switch AppConfig.appLanguage {
        case .en:
            return "https://hsr.pizzastudio.org/static/faq_en"
        case .zhcn, .zhtw:
            return "https://hsr.pizzastudio.org/static/faq"
        case .ja:
            return "https://hsr.pizzastudio.org/static/faq_ja"
        }
    }()

    @State private var selectedView: Navigation?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private func callMUISettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @ViewBuilder
    private func navigationDetail(selection: Binding<Navigation?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .accountManagement:
                ManageAccountsView()
            case .theFAQ:
                WebBrowserView(url: Self.faqURL)
                    .navigationTitle("sys.faq.title")
                    .navigationBarTitleDisplayMode(.inline)
            case .widgetSettings:
                WidgetSettingView()
            case .notificationSettings:
                NotificationSettingView()
            case .uiSettings:
                DisplayOptionsView()
            case .donation:
                GlobalDonateView()
            case .contact:
                ContactInfoView()
            case .moreSettings:
                OtherSettingsView()
            default: // case nil.
                DisplayOptionsView()
            }
        }
    }
}

// MARK: - OtherSettingsView

public struct OtherSettingsView: View {
    // MARK: Public

    @ViewBuilder public static var linksForManagingHoYoLabAccounts: some View {
        Link(destination: URL(string: "https://user.mihoyo.com/")!) {
            Text("sys.server.cn") + Text(verbatim: " - ") + Text("app.miyoushe")
        }
        Link(destination: URL(string: "https://account.hoyoverse.com/")!) {
            Text("sys.server.os") + Text(verbatim: " - HoYoLAB")
        }
    }

    public var body: some View {
        List {
            if AppConfig.isDebug {
                Button("Develop Settings") {
                    isDevelopSettingsShow.toggle()
                }
            }

            Section {
                NavigationLink("update.history.title") {
                    HistoryVersionInfoView()
                }
            }

            Section {
                PizzaAppMetaSet(
                    imageName: "icon.ophelper",
                    nameKey: "ophelper.name",
                    introKey: "ophelper.intro",
                    urlStr: "https://apps.apple.com/cn/app/id1635319193"
                )
                PizzaAppMetaSet(
                    imageName: "icon.herta_terminal",
                    nameKey: "herta_terminal.name",
                    introKey: "herta_terminal.intro",
                    urlStr: "https://apps.apple.com/cn/app/id6450712191"
                )
            } header: {
                Text("sys.about.otherapp.title")
            }
            Section {
                Link(destination: URL(string: "https://github.com/pizza-studio/hsrpizzahelper")!) {
                    Label {
                        Text("sys.about.opensource.title")
                    } icon: {
                        Image("icon.github").resizable().scaledToFit()
                    }
                }
            } footer: {
                Text("sys.about.opensource.footer")
            }

            Section {
                Menu {
                    Self.linksForManagingHoYoLabAccounts
                } label: {
                    Text("sys.manage_hoyolab_account")
                }
            } footer: {
                Text("sys.manage_hoyolab_account.footer").textCase(.none)
            }

            Section {
                Button {
                    Defaults.reset([.enkaDBData])
                } label: {
                    Label("sys.force_reset_enkaDB_cache", systemSymbol: .squareStack3dUp)
                }
            }

            if WatchConnectivityManager.isSupported {
                Section {
                    Button("sys.account.force_push") { forcePushAppleWatchContents() }
                } footer: {
                    Text("sys.account.force_push.footer").textCase(.none)
                }
            }

            Section {
                NavigationLink("app.userpolicy.title") {
                    let url: String = {
                        switch AppConfig.appLanguage {
                        case .en:
                            return "https://hsr.pizzastudio.org/static/policy_en"
                        case .zhcn, .zhtw:
                            return "https://hsr.pizzastudio.org/static/policy"
                        case .ja:
                            return "https://hsr.pizzastudio.org/static/policy_ja"
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
        .sheet(isPresented: $isDevelopSettingsShow, content: { DevelopSettings(isShow: $isDevelopSettingsShow) })
        .navigationTitle("sys.more.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Internal

    @State var isDevelopSettingsShow = false

    // MARK: Private

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>

    private func forcePushAppleWatchContents() {
        var accountInfo = "sys.account.force_push.received".localized()
        for account in accounts {
            accountInfo += "\(account.name!) (\(account.uid!))\n"
        }
        for account in accounts {
            WatchConnectivityManager.shared.sendAccounts(account, accountInfo)
        }
    }
}

// MARK: OtherSettingsView.PizzaAppMetaSet

extension OtherSettingsView {
    private struct PizzaAppMetaSet: Sendable, Identifiable, View {
        // MARK: Lifecycle

        public init(imageName: String, nameKey: String, introKey: String, urlStr: String) {
            self.imageName = imageName
            self.name = String(localized: .init(stringLiteral: nameKey))
            self.introduction = String(localized: .init(stringLiteral: introKey))
            self.destination = URL(string: urlStr)!
        }

        // MARK: Public

        public let name: String
        public let introduction: String
        public let destination: URL

        public var body: some View {
            Link(destination: destination) {
                HStack {
                    Image(imageName).resizable().frame(width: 50, height: 50).cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text(verbatim: name).foregroundColor(.primary)
                        Text(verbatim: introduction).font(.footnote).foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronForward)
                }
            }
        }

        // MARK: Internal

        let imageName: String

        var id: String { name }
    }
}
