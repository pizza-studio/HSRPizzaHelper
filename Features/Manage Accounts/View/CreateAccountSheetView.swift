//
//  AddAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - CreateAccountSheetView

struct CreateAccountSheetView: View {
    // MARK: Lifecycle

    init(account: Account, isShown: Binding<Bool>) {
        self._isShown = isShown
        self._account = StateObject(wrappedValue: account)
    }

    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                switch status {
                case .pending:
                    pendingView()
                case .gotCookie:
                    gotCookieView()
                case .gotAccount:
                    gotAccountView()
                }
            }
            .navigationTitle("account.new")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        saveAccount()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {

                    Button("Cancel") {
                        viewContext.delete(account)
                        isShown.toggle()
                    }
                }
            }
            .alert(isPresented: $isSaveAccountFailAlertShown, error: saveAccountError) {
                Button("sys.ok") {
                    isSaveAccountFailAlertShown.toggle()
                }
            }
            .onChange(of: status) { newValue in
                switch newValue {
                case .gotCookie:
                    getAccountForSelected()
                default:
                    return
                }
            }
        }
    }

    func saveAccount() {
        guard account.isValid() else {
            saveAccountError = .missingFieldError("err.mfe")
            isSaveAccountFailAlertShown.toggle()
            return
        }
        viewContext.performAndWait {
            do {
                try viewContext.save()
                isShown.toggle()
            } catch {
                saveAccountError = .saveDataError(error)
                isSaveAccountFailAlertShown.toggle()
            }
        }
    }

    func getAccountForSelected() {
        Task(priority: .userInitiated) {
            if let cookie = account.cookie {
                do {
                    accountsForSelected = try await MiHoYoAPI.getUserGameRolesByCookie(region: region, cookie: cookie)
                    selectedAccount.wrappedValue = accountsForSelected.first
                    status = .gotAccount
                } catch {
                    print(error)
                }
            }
        }
    }

    @ViewBuilder
    func pendingView() -> some View {
        Section {
            RequireLoginView(unsavedCookie: $account.cookie, region: $region)
            if let cookie = account.cookie {
                Text(cookie)
            }
        } footer: {
            VStack(alignment: .leading) {
                HStack {
                    Text("account.login.manual.1")
                        .font(.footnote)
                    NavigationLink {
                        AddAccountDetailView(
                            unsavedName: $account.name,
                            unsavedUid: $account.uid,
                            unsavedCookie: $account.cookie,
                            unsavedServer: $account.server
                        )
                    } label: {
                        Text("account.login.manual.2")
                            .font(.footnote)
                    }
                }
                if !account.isValid() {
                    ExplanationView()
                }
            }
        }
        .onChange(of: account.cookie) { newValue in
            if newValue != nil, newValue != "" {
                status = .gotCookie
            }
        }
    }

    @ViewBuilder
    func gotCookieView() -> some View {
        ProgressView()
    }

    @ViewBuilder
    func gotAccountView() -> some View {
        EditAccountView(account: account)
        Section {
            RequireLoginView(unsavedCookie: $account.cookie, region: $region)
        }

        Section {
            HStack {
                Text("account.label.nickname")
                Spacer()
                TextField("account.label.nickname", text: name, prompt: nil)
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
        Section {
            NavigationLink {
                AddAccountDetailView(
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

    // MARK: Private

    @Binding private var isShown: Bool

    @StateObject private var account: Account

    @Environment(\.managedObjectContext) private var viewContext

    @State private var isSaveAccountFailAlertShown: Bool = false
    @State private var saveAccountError: SaveAccountError?

    @State private var status: AddAccountStatus = .pending

    @State private var accountsForSelected: [FetchedAccount] = []

    @State private var region: Region = .china

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

    private var name: Binding<String> {
        .init {
            account.name ?? ""
        } set: { newValue in
            account.name = newValue
        }
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    @State var getCookieWebViewRegion: Region?

    @Binding var unsavedCookie: String?
    @Binding var region: Region

    var body: some View {
        Menu {
            Button("sys.server.cn") {
                getCookieWebViewRegion = .china
                region = .china
            }
            Button("sys.server.os") {
                getCookieWebViewRegion = .global
                region = .global
            }
        } label: {
            Group {
                if unsavedCookie == "" || unsavedCookie == nil {
                    Text("account.label.login")
                } else {
                    Text("account.label.relogin")
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .sheet(item: $getCookieWebViewRegion, content: { region in
            GetCookieWebView(
                isShown: .init(get: {
                    getCookieWebViewRegion != nil
                }, set: { newValue in
                    if !newValue {
                        getCookieWebViewRegion = nil
                    }
                }),
                cookie: $unsavedCookie,
                region: region
            )
        })
    }
}

// MARK: - AddAccountStatus

private enum AddAccountStatus {
    case pending
    case gotCookie
    case gotAccount
}

// MARK: - SaveAccountError

private enum SaveAccountError {
    case saveDataError(Error)
    case missingFieldError(String)
}

// MARK: LocalizedError

extension SaveAccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Account Fail\nSave Error: \(error).\nPlease try again."
        case let .missingFieldError(field):
            return "Save Account Fail\nMissing Fields: \(field).\nPlease try again."
        }
    }

    var failureReason: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Error: \(error)."
        case let .missingFieldError(field):
            return "Missing Fields: \(field)."
        }
    }

    var helpAnchor: String? {
        "Please try login again. "
    }
}

// MARK: - ExplanationView

private struct ExplanationView: View {
    var body: some View {
        Group {
            Divider()
                .padding(.vertical)
            Text("account.explanation.title.1")
                .font(.footnote)
                .bold()
            Text("account.explanation.1")
            .font(.footnote)
            Text("\n")
                .font(.footnote)
            Text("account.explanation.title.2")
                .font(.footnote)
                .bold()
            Text(
                "account.explanation.2"
            )
            .font(.footnote)
        }
    }
}

// MARK: - AddAccountDetailView

struct AddAccountDetailView: View {
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
                Picker("sys.label.server", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.description)
                            .tag(server)
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
