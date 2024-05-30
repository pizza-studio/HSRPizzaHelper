//
//  DailyNoteCards.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import SwiftUI

// MARK: - DailyNoteCards

let globalDailyNoteCardRefreshSubject: PassthroughSubject<Void, Never> = .init()

// MARK: - DailyNoteCards

struct DailyNoteCards: View {
    // MARK: Internal

    @State var isNewAccountSheetShow = false

    var body: some View {
        // Only compute once for each attempt of rendering this view.
        let validAccounts = accounts.filter(\.isValid)
        ForEach(validAccounts) { account in
            InAppDailyNoteCardView(account: account)
                .listRowMaterialBackground()
        }
        if validAccounts.isEmpty {
            AddNewAccountButton(
                isNewAccountSheetShow: $isNewAccountSheetShow
            )
            .listRowMaterialBackground()
            // .listRowBackground(Color.white.opacity(0))
        }
    }

    // MARK: Private

    private let refreshSubject: PassthroughSubject<Void, Never> = globalDailyNoteCardRefreshSubject

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
                        CreateAccountSheetView(
                            account: Account(context: viewContext),
                            isShown: $isNewAccountSheetShow
                        )
                        .scrollContentBackground(.visible)
                        .restoreSystemTint()
                    }
                Spacer()
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext
}
