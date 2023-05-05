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

    var body: some View {
        Section {
            RequireLoginView(
                unsavedCookie: $account.cookie,
                region: account.server.region
            )
        }
        Section {
            HStack {
                Text("Nickname")
                Spacer()
                TextField("Nickname", text: $account.name, prompt: nil)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            HStack {
                Text("UID: " + (account.uid ?? ""))
                Spacer()
                Text(account.server.description)
            }
        }
        Section {
            NavigationLink {
                AddAccountDetailView(
                    unsavedName: $account.name,
                    unsavedUid: $account.uid,
                    unsavedCookie: $account.cookie,
                    unsavedServer: $account.server
                )
            } label: {
                Text("Account Detail")
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
            Text("Re-Login")
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
