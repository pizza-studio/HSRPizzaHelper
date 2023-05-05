//
//  EditAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - EditAccountView

struct EditAccountView: View {
    @StateObject var account: Account

    var accountsForSelected: [FetchedAccount]?

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
                TextField("account.label.nickname", text: $account.name, prompt: nil)
                    .multilineTextAlignment(.trailing)
            }
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
                    unsavedServer: $account.server
                )
            } label: {
                Text("account.label.detail")
            }
        }
        Section {
            TestAccountView(account: account)
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
            GetCookieWebView(
                isShown: $isGetCookieWebViewShown,
                cookie: $unsavedCookie,
                region: region
            )
        })
    }
}

private struct SelectAccountView: View {
    init(account: Account, accountsForSelected: [FetchedAccount]) {
        self._account = ObservedObject(wrappedValue: account)
        self.accountsForSelected = accountsForSelected
        selectedAccount.wrappedValue = accountsForSelected.first
    }

    @ObservedObject var account: Account

    let accountsForSelected: [FetchedAccount]

    @MainActor
    private var selectedAccount: Binding<FetchedAccount?> {
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
}
