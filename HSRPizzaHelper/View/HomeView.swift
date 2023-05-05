//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import HBMihoyoAPI
import SwiftUI

struct HomeView: View {
    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    if account.isValid() {
                        InAppDailyNoteCardView(account: account)
                    }
                }
            }
            .navigationTitle("home.title")
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}
