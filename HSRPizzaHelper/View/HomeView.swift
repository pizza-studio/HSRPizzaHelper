//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SwiftUI
import CoreData
import HBMihoyoAPI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    if account.isValid() {
                        InAppDailyNoteCardView(account: account)
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}
