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
        unsavedServer: Binding<Server>,
        unsavedDeviceFingerPrint: Binding<String>
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
        _deviceFingerPrint = unsavedDeviceFingerPrint
    }

    // MARK: Internal

    @Binding var unsavedName: String
    @Binding var unsavedUid: String
    @Binding var unsavedCookie: String
    @Binding var unsavedServer: Server
    @Binding var deviceFingerPrint: String

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
                Picker("sys.label.server", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.description).tag(server)
                    }
                }
            }

            Section {
                let cookieTextEditorFrame: CGFloat = 150
                TextEditor(text: $unsavedCookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("sys.label.cookie")
                    .textCase(.none)
            }
            Section {
                TextField("account.fp.label", text: $deviceFingerPrint)
                    .multilineTextAlignment(.leading)
            } header: {
                Text("account.fp.label")
                    .textCase(.none)
            } footer: {
                Text("account.fp.footer")
                    .textCase(.none)
            }
        }
        .navigationBarTitle("account.label.detail", displayMode: .inline)
    }
}
