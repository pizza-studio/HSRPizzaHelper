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
            Section {
                Button {
                    sheetType = .createNewAccount
                } label: {
                    Label("account.new", systemSymbol: .plusCircle)
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
            }
        }
        .navigationTitle("account.manage.title")
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
            case let .editExistedAccount(account):
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

    private enum SheetType: Identifiable {
        case createNewAccount
        case editExistedAccount(Account)

        // MARK: Internal

        var id: UUID {
            switch self {
            case .createNewAccount:
                return UUID()
            case let .editExistedAccount(account):
                return account.uuid ?? UUID()
            }
        }
    }

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
}
