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
            if accounts.isEmpty {
                Button("Add you account first") {
                    isAddAccountSheetShown.toggle()
                }
            } else {
                ForEach(accounts) { account in
                    if let name = account.name {
                        Text(name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Manage Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddAccountSheetShown) {
            AddAccountView(isShown: $isAddAccountSheetShown)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isAddAccountSheetShown.toggle()
                } label: {
                    Image(systemSymbol: .plusCircle)
                }
            }
        }
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

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Account.priority, ascending: true),
        ],
        animation: .default
    )
    private var accounts: FetchedResults<Account>

    @State
    private var isAddAccountSheetShown: Bool = false

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
