//
//  AddAccountDetailView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//
//  添加帐号页面的详细信息

import HBMihoyoAPI
import SwiftUI

struct AddAccountDetailView: View {
    @Binding
    var unsavedName: String
    @Binding
    var unsavedUid: String
    @Binding
    var unsavedCookie: String
    @Binding
    var unsavedServer: Server
    @Binding
    var connectStatus: ConnectStatus

    var body: some View {
        List {
            Section(header: Text("帐号配置")) {
                InfoEditor(
                    title: "UID",
                    content: $unsavedUid,
                    keyboardType: .numberPad
                )
                NavigationLink(destination: TextEditorView(
                    title: "Cookie",
                    content: $unsavedCookie,
                    showPasteButton: true,
                    showShortCutsLink: true
                )) {
                    Text("Cookie")
                }
                Picker("服务器", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }
            if unsavedUid != "", unsavedCookie != "" {
                TestSectionView(
                    connectStatus: $connectStatus,
                    uid: $unsavedUid,
                    cookie: $unsavedCookie,
                    server: $unsavedServer
                )
            }
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
    }
}
