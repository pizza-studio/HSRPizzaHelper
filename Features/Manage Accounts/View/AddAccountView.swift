//
//  AddAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SwiftUI
import HBMihoyoAPI

struct AddAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var isShown: Bool

    @StateObject var account: Account

    @State private var isSaveAccountFailAlertShown: Bool = false
    @State private var saveAccountError: SaveAccountError?

    @State private var status: AddAccountStatus = .pending

    @State
    private var accountsForSelected: [FetchedAccount] = []

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

    init(isShown: Binding<Bool>) {
        self._isShown = isShown
        let account = Account(context: AccountPersistenceController.shared.container.viewContext)
        account.uuid = UUID()
        account.priority = 0
        account.serverRawValue = Server.china.rawValue
        self._account = StateObject(wrappedValue: account)
    }

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
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                Button("OK") {
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
            .onDisappear {
                if !account.isValid() {
                    viewContext.delete(account)
                }
            }
        }
    }

    func saveAccount() {
        guard account.isValid() else {
            saveAccountError = .missingFieldError("Missing Field")
            isSaveAccountFailAlertShown.toggle()
            return
        }
        do {
            try viewContext.save()
            isShown.toggle()
        } catch {
            saveAccountError = .saveDataError(error)
            isSaveAccountFailAlertShown.toggle()
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
                    Text("You can also")
                        .font(.footnote)
                    NavigationLink {
                        AddAccountDetailView(unsavedName: $account.name, unsavedUid: $account.uid, unsavedCookie: $account.cookie, unsavedServer: $account.server)
                    } label: {
                        Text("manually config your account")
                            .font(.footnote)
                    }
                }
                if !account.isValid() {
                    ExplanationView()
                }
            }
        }
        .onChange(of: account.cookie) { newValue in
            if newValue != nil && newValue != "" {
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
        Section {
            HStack {
                Text("Nickname")
                Spacer()
                TextField("自定义账号名", text: name, prompt: nil)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            HStack {
                Text("UID: " + (account.uid ?? ""))
                Spacer()
                Text(account.server.rawValue)
            }
        }
        Section {
            // 如果该帐号绑定的UID不止一个，则显示Picker选择帐号
            if accountsForSelected.count > 1 {
                Picker("请选择帐号", selection: selectedAccount) {
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
                AddAccountDetailView(unsavedName: $account.name, unsavedUid: $account.uid, unsavedCookie: $account.cookie, unsavedServer: $account.server)
            } label: {
                Text("Account Detail")
            }
        }
    }
}

struct RequireLoginView: View {
    @State var getCookieWebViewRegion: Region?

    @Binding var unsavedCookie: String?
    @Binding var region: Region

    var body: some View {
        Menu {
            Button("国服") {
                getCookieWebViewRegion = .china
                region = .china
            }
            Button("国际服") {
                getCookieWebViewRegion = .global
                region = .global
            }
        } label: {
            Group {
                if unsavedCookie == "" || unsavedCookie == nil {
                    Text("Login")
                } else {
                    Text("Re-Login")
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

private enum AddAccountStatus {
    case pending
    case gotCookie
    case gotAccount
}

private enum SaveAccountError {
    case saveDataError(Error)
    case missingFieldError(String)
}

extension SaveAccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveDataError(let error):
            return "Save Account Fail\nSave Error: \(error).\nPlease try again."
        case .missingFieldError(let field):
            return "Save Account Fail\nMissing Fields: \(field).\nPlease try again."
        }
    }
    var failureReason: String? {
        switch self {
        case .saveDataError(let error):
            return "Save Error: \(error)."
        case .missingFieldError(let field):
            return "Missing Fields: \(field)."
        }
    }

    var helpAnchor: String? {
        "Please try login again. "
    }
}

private struct ExplanationView: View {
    var body: some View {
        Group {
            Divider()
                .padding(.vertical)
            Text("关于我们的工作原理")
                .font(.footnote)
                .bold()
            Text(
                "为了请求您的游戏内的数据，我们需要获取您的UID和Cookie，这是获取数据的必要参数。您在接下来的网页登录后，我们会在您的本地和iCloud存储您的个人数据。然后我们通过类似米游社的方式获取您的游戏内的数据信息。我们承诺，您的个人信息不会发送给任何人，包括我们自己。您的个人信息将会是非常安全的。"
            )
            .font(.footnote)
            Text("\n")
                .font(.footnote)
            Text("关于您的帐号安全")
                .font(.footnote)
                .bold()
            Text(
                "本程序不属于外挂等违法程序。本程序遵守米哈游二次创作规则的相关内容。根据中国原神客服的答复，使用本程序不会造成封号等问题。具体内容参见设置 - FAQ."
            )
            .font(.footnote)
        }
    }
}

struct AddAccountDetailView: View {
    @Binding
    var unsavedName: String
    @Binding
    var unsavedUid: String
    @Binding
    var unsavedCookie: String
    @Binding
    var unsavedServer: Server

    init(
        unsavedName: Binding<String?>,
        unsavedUid: Binding<String?>,
        unsavedCookie: Binding<String?>,
        unsavedServer: Binding<Server>
    ) {
        self._unsavedName = .init(get: {
            unsavedName.wrappedValue ?? ""
        }, set: { newValue in
            unsavedName.wrappedValue = newValue
        })
        self._unsavedUid = .init(get: {
            unsavedUid.wrappedValue ?? ""
        }, set: { newValue in
            unsavedUid.wrappedValue = newValue
        })
        self._unsavedCookie = .init(get: {
            unsavedCookie.wrappedValue ?? ""
        }, set: { newValue in
            unsavedCookie.wrappedValue = newValue
        })
        self._unsavedServer = unsavedServer
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Nickname")
                    Spacer()
                    TextField("Nickname", text: $unsavedName, prompt: Text("Nickname"))
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("UID")
                    Spacer()
                    TextField("UID", text: $unsavedUid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                Picker("Server", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }
            Section {
                TextEditor(text: $unsavedCookie)
                    .frame(height: 350)
            } header: {
                Text("Cookie")
            }
        }
        .navigationBarTitle("Account Detail", displayMode: .inline)
    }
}

