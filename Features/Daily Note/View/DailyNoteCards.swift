//
//  DailyNoteCards.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import SwiftUI

// MARK: - DailyNoteCards

let globalDailyNoteCardRefreshSubject: PassthroughSubject<(), Never> = .init()

// MARK: - DailyNoteCards

struct DailyNoteCards: View {
    // MARK: Internal

    @State var isNewAccountSheetShow = false

    var body: some View {
        ForEach(accounts) { account in
            if account.isValid() {
                InAppDailyNoteCardView(
                    account: account
                )
            }
        }
        Button("Sync to Watch") {
            var accountInfo = "Accounts:\n"
            for account in accounts {
                accountInfo += "\(String(describing: account.name!)) \(String(describing: account.uid!))\n"
            }
//            WatchConnectivityManager.shared.send(accountInfo)
//            WatchConnectivityManager.shared.sendAccounts(Array(accounts), accountInfo)
            for account in accounts {
                WatchConnectivityManager.shared.sendAccounts(account, accountInfo)
            }
        }
        if accounts.filter({ $0.isValid() }).isEmpty {
            AddNewAccountButton(
                isNewAccountSheetShow: $isNewAccountSheetShow
            )
            .listRowBackground(Color.white.opacity(0))
        }
    }

    // MARK: Private

    private let refreshSubject: PassthroughSubject<(), Never> = globalDailyNoteCardRefreshSubject

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var alertToastVariable: AlertToastVariable

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}

// MARK: - AddNewAccountButton

private struct AddNewAccountButton: View {
    // MARK: Internal

    @Binding var isNewAccountSheetShow: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Label("account.new", systemSymbol: .plusCircle)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 4)
                    )
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .contentShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .clipShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .onTapGesture {
                        isNewAccountSheetShow.toggle()
                    }
                    .sheet(isPresented: $isNewAccountSheetShow) {
                        CreateAccountSheetView(account: Account(context: viewContext), isShown: $isNewAccountSheetShow)
                    }
                Spacer()
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext
}
