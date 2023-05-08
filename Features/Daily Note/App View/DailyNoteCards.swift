//
//  DailyNoteCards.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import SwiftUI

struct DailyNoteCards: View {
    // MARK: Internal

    @State var isNewAccountSheetShow = false

    let refreshSubject: PassthroughSubject<(), Never>

    var body: some View {
        ForEach(accounts) { account in
            if account.isValid() {
                InAppDailyNoteCardView(account: account, refreshSubject: refreshSubject)
            }
        }
        if accounts.filter({ $0.isValid() }).isEmpty {
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
            .listRowBackground(Color.white.opacity(0))
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}
