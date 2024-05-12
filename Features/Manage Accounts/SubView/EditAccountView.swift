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
                AccountDetailView(
                    unsavedName: $account.name,
                    unsavedUid: $account.uid,
                    unsavedCookie: $account.cookie,
                    unsavedServer: $account.server,
                    unsavedDeviceFingerPrint: $account.deviceFingerPrint
                )
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
    @Binding var unsavedCookie: String?

    @State private var isGetCookieWebViewShown: Bool = false

    let region: Region

    var body: some View {
        Button {
            isGetCookieWebViewShown.toggle()
        } label: {
            Text("account.label.relogin")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .sheet(isPresented: $isGetCookieWebViewShown, content: {
            switch region {
            case .mainlandChina:
                QRCodeGetCookieView(cookie: $unsavedCookie)
            case .global:
                GetCookieWebView(
                    isShown: $isGetCookieWebViewShown,
                    cookie: $unsavedCookie,
                    region: region
                )
            }
        })
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
