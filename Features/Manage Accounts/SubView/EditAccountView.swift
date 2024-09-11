//
//  EditAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import HBMihoyoAPI
import SwiftUI

// MARK: - EditAccountView

struct EditAccountView: View {
    // MARK: Internal

    @StateObject var account: Account

    var accountsForSelected: [FetchedAccount]?
    @State var validate: String = ""

    var body: some View {
        Section {
            RequireLoginView(
                unsavedCookie: $account.cookie,
                unsavedFP: $account.deviceFingerPrint,
                region: account.server.region
            )
        }
        Section {
            HStack {
                Text("account.label.nickname")
                Spacer()
                TextField("account.label.nickname", text: accountName)
                    .multilineTextAlignment(.trailing)
            }
            Toggle("account.setting.allownotification", isOn: allowNotification)
        } header: {
            HStack {
                Text("UID: " + (account.uid ?? ""))
                Spacer()
                Text(account.server.description)
            }
        }
        if let accountsForSelected = accountsForSelected {
            SelectAccountView(account: account, accountsForSelected: accountsForSelected)
        }
        Section {
            NavigationLink {
                AccountDetailView(account: account)
            } label: {
                Text("account.label.detail")
            }
        }

        TestAccountSectionView(account: account)
    }

    // MARK: Private

    private var accountName: Binding<String> {
        .init {
            account.name ?? ""
        } set: { newValue in
            account.name = newValue
        }
    }

    private var allowNotification: Binding<Bool> {
        .init {
            account.allowNotification as? Bool ?? true
        } set: { newValue in
            account.allowNotification = newValue as NSNumber
        }
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    // MARK: Internal

    @Binding var unsavedCookie: String?
    @Binding var unsavedFP: String

    let region: Region

    var body: some View {
        NavigationLink {
            handleSheetNavigation()
        } label: {
            Text("settings.account.loginViaMiyousheOrHoyoLab.relogin")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .foregroundColor(.accentColor)
    }

    // MARK: Private

    private func handleSheetNavigation() -> some View {
        Group {
            switch region {
            case .mainlandChina:
                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP)
            case .global:
                GetCookieWebView(cookie: $unsavedCookie, region: region)
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
        .toolbar(.hidden, for: .tabBar)
        #endif
        // 逼着用户改用自订的后退按钮。
        // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
        // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - SelectAccountView

private struct SelectAccountView: View {
    // MARK: Lifecycle

    init(account: Account, accountsForSelected: [FetchedAccount]) {
        self._account = ObservedObject(wrappedValue: account)
        self.accountsForSelected = accountsForSelected
    }

    // MARK: Internal

    @ObservedObject var account: Account

    let accountsForSelected: [FetchedAccount]

    var body: some View {
        Section {
            // 如果该帐号绑定的UID不止一个，则显示Picker选择帐号
            if accountsForSelected.count > 1 {
                Picker("account.label.select", selection: selectedAccount) {
                    ForEach(
                        accountsForSelected,
                        id: \.gameUid
                    ) { account in
                        Text(account.nickname + "（\(account.gameUid)）")
                            .tag(account as FetchedAccount?)
                    }
                }
            }
        }
    }

    // MARK: Private

    @MainActor private var selectedAccount: Binding<FetchedAccount?> {
        .init {
            accountsForSelected.first { account in
                account.gameUid == self.account.uid
            }
        } set: { account in
            if let account = account {
                self.account.name = account.nickname
                self.account.uid = account.gameUid
                self.account.server = Server(rawValue: account.region) ?? .china
            }
        }
    }
}
