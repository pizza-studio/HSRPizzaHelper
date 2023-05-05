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

    let refreshSubject: PassthroughSubject<(), Never>

    var body: some View {
        ForEach(accounts) { account in
            if account.isValid() {
                InAppDailyNoteCardView(account: account, refreshSubject: refreshSubject)
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}
