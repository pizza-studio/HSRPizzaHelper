//
//  ManageAccountsView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SwiftUI

struct ManageAccountsView: View {
    // MARK: Internal

    var body: some View {
        List {
            Button {
                sheetType = .createNewAccount
            } label: {
                Label("Add new account", systemSymbol: .plusCircle)
            }
            ForEach(accounts) { account in
                Button {
                    sheetType = .editExistedAccount(account)
                } label: {
                    Text(account.name ?? "")
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Manage Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheetType, content: { type in
            let isShown: Binding<Bool> = .init {
                sheetType != nil
            } set: { newValue in
                if !newValue { sheetType = nil }
            }
            switch type {
            case .createNewAccount:
                ManageAccountSheetView(isShown: isShown)
            case .editExistedAccount(let account):
                ManageAccountSheetView(account: account, isShown: isShown)
            }
        })
        .onAppear {
            accounts.forEach { account in
                if !account.isValid() {
                    viewContext.delete(account)
                    try? viewContext.save()
                }
            }
        }
    }

    // MARK: Private

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
            offsets.map { accounts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }

    private enum SheetType: Identifiable {
        case createNewAccount
        case editExistedAccount(Account)

        var id: UUID {
            switch self {
            case .createNewAccount:
                return UUID()
            case .editExistedAccount(let account):
                return account.uuid ?? UUID()
            }
        }
    }
}
