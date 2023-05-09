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

    init(
        unsavedName: Binding<String?>,
        unsavedUid: Binding<String?>,
        unsavedCookie: Binding<String?>,
        unsavedServer: Binding<Server>
    ) {
        _unsavedName = .init(get: {
            unsavedName.wrappedValue ?? ""
        }, set: { newValue in
            unsavedName.wrappedValue = newValue
        })
        _unsavedUid = .init(get: {
            unsavedUid.wrappedValue ?? ""
        }, set: { newValue in
            unsavedUid.wrappedValue = newValue
        })
        _unsavedCookie = .init(get: {
            unsavedCookie.wrappedValue ?? ""
        }, set: { newValue in
            unsavedCookie.wrappedValue = newValue
        })
        _unsavedServer = unsavedServer
    }

    // MARK: Internal

    @Binding var unsavedName: String
    @Binding var unsavedUid: String
    @Binding var unsavedCookie: String
    @Binding var unsavedServer: Server

    var body: some View {
        List {
            Section {
                HStack {
                    Text("account.label.nickname")
                    Spacer()
                    TextField("account.label.nickname", text: $unsavedName, prompt: Text("account.label.nickname"))
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("UID")
                    Spacer()
                    TextField("UID", text: $unsavedUid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                // Server Picker.
                // I don't know why SwiftUI `Picker` does not work here.
                // So I use `Menu` instead.
                HStack {
                    Text("sys.label.server")
                        .foregroundColor(.primary)
                    Spacer()
                    Menu {
                        ForEach(Server.allCases, id: \.self) { server in
                            Button(server.description) {
                                unsavedServer = server
                            }
                        }
                    } label: {
                        Group {
                            Text(unsavedServer.description)
                            Image(systemSymbol: .chevronUpChevronDown)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            Section {
                let cookieTextEditorFrame: CGFloat = 350
                TextEditor(text: $unsavedCookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("sys.label.cookie")
            }
        }
        .navigationBarTitle("account.label.detail", displayMode: .inline)
    }
}
