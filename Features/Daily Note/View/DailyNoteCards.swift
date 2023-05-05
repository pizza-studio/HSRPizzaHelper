//
//  DailyNoteCards.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import SwiftUI
import Combine

struct DailyNoteCards: View {
    let refreshSubject: PassthroughSubject<(), Never>

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>

    var body: some View {
        ForEach(accounts) { account in
            if account.isValid() {
                InAppDailyNoteCardView(account: account, refreshSubject: refreshSubject)
            }
        }
    }
}
