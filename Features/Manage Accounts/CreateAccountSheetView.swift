//
//  AddAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import HBMihoyoAPI
import SwiftUI
import WidgetKit

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
                        alertToastVariable.isDoneButtonTapped.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        viewContext.rollback()
                        isShown.toggle()
                    }
                }
            }
            .alert(isPresented: $isSaveAccountFailAlertShown, error: saveAccountError) {
                Button("sys.ok") {
                    isSaveAccountFailAlertShown.toggle()
                }
            }
            .alert(isPresented: $isGetAccountFailAlertShown, error: getAccountError) {
                Button("sys.ok") {
                    isGetAccountFailAlertShown.toggle()
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
                Task {
                    do {
                        _ = try await HSRNotificationCenter.requestAuthorization()
                    } catch {
                        print(error)
                    }
                }
                WidgetCenter.shared.reloadAllTimelines()
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
                    if let account = accountsForSelected.first {
                        self.account.name = account.nickname
                        self.account.uid = account.gameUid
                        self.account.server = Server(rawValue: account.region) ?? .china
                    } else {
                        getAccountError = .customize("account.login.error.no.account.found")
                    }
                    status = .gotAccount
                } catch {
                    getAccountError = .source(error)
                    isGetAccountFailAlertShown.toggle()
                    status = .pending
                }
            }
        }
    }

    @ViewBuilder
    func pendingView() -> some View {
        Section {
            RequireLoginView(unsavedCookie: $account.cookie, region: $region)
        } footer: {
            VStack(alignment: .leading) {
                HStack {
                    Text("account.login.manual.1")
                        .font(.footnote)
                    NavigationLink {
                        AccountDetailView(
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
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    func gotCookieView() -> some View {
        ProgressView()
    }

    @ViewBuilder
    func gotAccountView() -> some View {
        EditAccountView(account: account, accountsForSelected: accountsForSelected)
    }

    // MARK: Private

    @EnvironmentObject private var alertToastVariable: AlertToastVariable

    @Binding private var isShown: Bool

    @StateObject private var account: Account

    @Environment(\.managedObjectContext) private var viewContext

    @State private var isSaveAccountFailAlertShown: Bool = false
    @State private var saveAccountError: SaveAccountError?

    @State private var isGetAccountFailAlertShown: Bool = false
    @State private var getAccountError: GetAccountError?

    @State private var status: AddAccountStatus = .pending

    @State private var accountsForSelected: [FetchedAccount] = []

    @State private var region: Region = .china

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
            Button("account.create.server.os.notsupport") {
                getCookieWebViewRegion = .global
                region = .global
            }
            .disabled(true)
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

// MARK: - GetAccountError

private enum GetAccountError: LocalizedError {
    case source(Error)
    case customize(String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case let .source(error):
            return error.localizedDescription
        case let .customize(message):
            return message
        }
    }
}

// MARK: - ExplanationView

private struct ExplanationView: View {
    var body: some View {
        Group {
            Divider()
                .padding(.vertical)
            Text("sys.warning.osservers")
                .font(.footnote)
            Text("\n")
                .font(.footnote)
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
            Text("account.explanation.2")
                .font(.footnote)
        }
    }
}
