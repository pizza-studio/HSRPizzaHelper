//
//  ManageAccountsView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import AlertToast
import Defaults
import SwiftUI

// MARK: - AlertToastVariable

class AlertToastVariable: ObservableObject {
    @Published var isDoneButtonTapped: Bool = false
    @Published var isLoginSucceeded: Bool = false
}

// MARK: - ManageAccountsView

struct ManageAccountsView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Button {
                    sheetType = .createNewAccount(Account(context: viewContext))
                } label: {
                    Label("account.new", systemSymbol: .plusCircle)
                }
            } footer: {
                NavigationLink {
                    AccountWithdrawalView()
                } label: {
                    Text("account.withdraw.entrylink.title")
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                }
            }
            Section {
                ForEach(accounts) { account in
                    Button {
                        sheetType = .editExistedAccount(account)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(account.name ?? "")
                                    .foregroundColor(.primary)
                                HStack {
                                    Text(account.uid ?? "")
                                    Text(account.server.description)
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemSymbol: .sliderHorizontal3)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
        }
        .navigationTitle("account.manage.title")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheetType, content: { type in
            switch type {
            case let .createNewAccount(newAccount):
                CreateAccountSheetView(account: newAccount, isShown: isShown)
            case let .editExistedAccount(account):
                EditAccountSheetView(account: account, isShown: isShown)
            }
        })
        .onAppear {
            accounts.filter(\.isInvalid).forEach { account in
                viewContext.delete(account)
                try? viewContext.save()
            }
        }
        .toolbar {
            EditButton()
        }
        .toast(isPresenting: $alertToastVariable.isDoneButtonTapped) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "account.added.success"
            )
        }
        .environmentObject(alertToastVariable)
    }

    var isShown: Binding<Bool> {
        .init {
            sheetType != nil
        } set: { newValue in
            if !newValue { sheetType = nil }
        }
    }

    // MARK: Private

    private enum SheetType: Identifiable {
        case createNewAccount(Account)
        case editExistedAccount(Account)

        // MARK: Internal

        var id: UUID {
            switch self {
            case let .createNewAccount(account):
                return account.uuid ?? UUID()
            case let .editExistedAccount(account):
                return account.uuid ?? UUID()
            }
        }
    }

    @StateObject private var alertToastVariable = AlertToastVariable()

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Account.priority, ascending: true),
        ],
        animation: .default
    ) private var accounts: FetchedResults<Account>

    @State private var sheetType: SheetType?

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var idsToDrop: [String] = []
            offsets.map {
                let returned = accounts[$0]
                idsToDrop.append(returned.uid)
                return returned
            }.forEach(viewContext.delete)

            defer {
                // 特殊处理：当且仅当当前删掉的帐号不是重复的帐号的时候，才清空展柜缓存。
                let remainingUIDs = accounts.map(\.uid)
                idsToDrop.forEach { currentUID in
                    if !remainingUIDs.contains(currentUID) {
                        Defaults[.queriedEnkaProfiles].removeValue(forKey: currentUID)
                    }
                }
            }

            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            var revisedAccounts: [Account] = accounts.map { $0 }
            revisedAccounts.move(fromOffsets: source, toOffset: destination)

            for (index, account) in revisedAccounts.enumerated() {
                account.priority = index as NSNumber
            }

            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - AccountWithdrawalView

struct AccountWithdrawalView: View {
    // MARK: Internal

    var body: some View {
        let urlStrHoYoLab = "https://account.hoyoverse.com/#/account/safetySettings"
        let urlStrMiyoushe = "https://user.mihoyo.com/#/account/closeAccount"
        List {
            Section {
                Label {
                    HStack {
                        Text("account.withdrawal.warning")
                            .foregroundStyle(.red)
                    }
                } icon: {
                    Image(systemSymbol: .exclamationmarkOctagonFill)
                        .foregroundStyle(.red)
                }
                .font(.headline)
            } footer: {
                VStack(alignment: .leading) {
                    Text("account.withdrawal.warning.footer")
                    Text("account.withdrawal.whyAddedThisPage.description")
                }.multilineTextAlignment(.leading)
            }

            Section {
                Link(destination: URL(string: Self.hoyolabStorePage)!) {
                    Text(verbatim: "HoYoLAB on App Store")
                }
                NavigationLink {
                    WebBrowserView(url: urlStrHoYoLab)
                        .navigationTitle("account.withdrawal.navTitle.hoyolab")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Text("sys.server.os") + Text(verbatim: " - HoYoLAB")
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text("account.withdrawal.linkTo:\(urlStrHoYoLab)")
                    Text("account.withdrawal.readme.hoyolab.specialNotice")
                }
            }

            Section {
                if Self.isMiyousheInstalled {
                    Link(destination: URL(string: Self.miyousheHeader + "me")!) {
                        Text("account.qr_code_login.open_miyoushe")
                    }
                } else {
                    Link(destination: URL(string: Self.miyousheStorePage)!) {
                        Text("account.qr_code_login.open_miyoushe_mas_page")
                    }
                }
                NavigationLink {
                    WebBrowserView(url: urlStrMiyoushe)
                        .navigationTitle("account.withdrawal.navTitle.miyoushe")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Text("sys.server.cn") + Text(verbatim: " - ") + Text("app.miyoushe")
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text("account.withdrawal.linkTo:\(urlStrMiyoushe)")
                    Text("account.withdrawal.readme.miyoushe.specialNotice")
                }
            }
        }.navigationTitle("account.withdraw.view.title")
    }

    // MARK: Private

    private static var isMiyousheInstalled: Bool {
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    private static var hoyolabStorePage: String {
        "https://apps.apple.com/app/hoyolab/id1559483982"
    }

    @State private var sheetHoyolabPresented: Bool = false
    @State private var sheetMiyoushePresented: Bool = false
}
