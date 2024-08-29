//
//  AccountDetailView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import HBMihoyoAPI
import SwiftUI

struct AccountDetailView: View {
    // MARK: Lifecycle

    init(account: Account) {
        self._account = ObservedObject(wrappedValue: account)
    }

    // MARK: Internal

    @ObservedObject var account: Account

    var body: some View {
        List {
            Section {
                HStack {
                    Text("account.label.nickname")
                    Spacer()
                    TextField("account.label.nickname", text: $account.name, prompt: Text("account.label.nickname"))
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("UID")
                    Spacer()
                    TextField("UID", text: $account.uid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                Picker("sys.label.server", selection: $account.server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.description).tag(server)
                    }
                }
            }

            Section {
                let cookieTextEditorFrame: CGFloat = 150
                TextEditor(text: $account.cookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("sys.label.cookie")
                    .textCase(.none)
            }
            Section {
                TextField("account.fp.label", text: $account.deviceFingerPrint)
                    .multilineTextAlignment(.leading)
            } header: {
                Text("account.fp.label")
                    .textCase(.none)
            }
        }
        .navigationBarTitle("account.label.detail", displayMode: .inline)
    }
}
