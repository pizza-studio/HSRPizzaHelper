//
//  ContentView.swift
//  HSRPizzaHelperWatch Watch App
//
//  Created by Bill Haku on 2023/7/7.
//

import SwiftUI

// MARK: - ContentView

struct WatchContentView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                DailyNoteCards()
            }
            .navigationTitle("home.title")
            .alert(item: $connectivityManager.notificationMessage) { message in
                Alert(
                    title: Text(message.text),
                    dismissButton: .default(Text("Dismiss"))
                )
            }
            .onChange(of: connectivityManager.sharedAccounts) { newAccounts in
                print("Received account (\(newAccounts.count): ")
                for account in newAccounts {
                    print("\(account.name!): \(account.uid!) \(account.cookie!)")
                }
            }
        }
    }

    // MARK: Private

    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
}
