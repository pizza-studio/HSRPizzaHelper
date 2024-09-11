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
                if status != .pending {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("sys.done") {
                            saveAccount()
                            globalDailyNoteCardRefreshSubject.send(())
                            alertToastVariable.isDoneButtonTapped.toggle()
                        }
                        .disabled(status != .gotAccount)
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        menuForManagingHoYoLabAccounts()
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
        guard account.isValid else {
            saveAccountError = .missingFieldError(
                String(localized: .init(stringLiteral: "err.mfe"))
            )
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
                    // Device fingerPrint for MiYouShe accounts are already fetched in GetCookieQRCodeView.
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
    func menuForManagingHoYoLabAccounts() -> some View {
        Menu {
            OtherSettingsView.linksForManagingHoYoLabAccounts
        } label: {
            Text("account.login.manageLink.shortened")
        }
    }

    @ViewBuilder
    func pendingView() -> some View {
        Group {
            Section {
                RequireLoginView(unsavedCookie: $account.cookie, unsavedFP: $account.deviceFingerPrint, region: $region)
            } footer: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("account.login.manual.1")
                        NavigationLink {
                            AccountDetailView(account: account)
                        } label: {
                            Text("account.login.manual.2")
                                .font(.footnote)
                        }
                    }
                    Divider().padding(.vertical)
                    ExplanationView()
                }
            }
        }
        .onChange(of: account.cookie) { _ in
            if account.hasValidCookie {
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

    @State private var region: Region = .mainlandChina

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
    // MARK: Internal

    @Binding var unsavedCookie: String?
    @Binding var unsavedFP: String
    @Binding var region: Region

    var body: some View {
        Picker("".description, selection: $region) {
            Text("sys.server.cn").tag(Region.mainlandChina)
            Text("sys.server.os").tag(Region.global)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        NavigationLink {
            handleSheetNavigation()
        } label: {
            Text(
                isUnsavedCookieInvalid
                    ? "settings.account.loginViaMiyousheOrHoyoLab"
                    : "settings.account.loginViaMiyousheOrHoyoLab.relogin"
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .foregroundColor(.accentColor)
    }

    // MARK: Private

    private var isUnsavedCookieInvalid: Bool {
        (unsavedCookie ?? "").isEmpty
    }

    private func handleSheetNavigation() -> some View {
        Group {
            switch region {
            case .mainlandChina:
                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP)
            case .global:
                GetCookieWebView(cookie: $unsavedCookie, region: region)
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
        .toolbar(.hidden, for: .tabBar)
        #endif
        // 逼着用户改用自订的后退按钮。
        // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
        // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
        .navigationBarBackButtonHidden(true)
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
    // MARK: Internal

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 9) {
                Text(verbatim: beareOfTextHeader)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.red)
                ForEach(beareOfTextContents, id: \.self) { currentLine in
                    Text(verbatim: currentLine)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Text("account.explanation.title.1")
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("account.explanation.1")
                    .font(.subheadline)
                Text("account.explanation.title.2")
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("account.explanation.2")
                    .font(.subheadline)
            }
        }
    }

    // MARK: Private

    private let bewareOfTextLines: [String] = String(
        localized: .init(stringLiteral: "account.notice.bewareof")
    ).split(separator: "\n\n").map(\.description)

    private var beareOfTextHeader: String {
        bewareOfTextLines.first ?? "BewareOf_Header"
    }

    private var beareOfTextContents: [String] {
        Array(bewareOfTextLines.dropFirst())
    }
}
