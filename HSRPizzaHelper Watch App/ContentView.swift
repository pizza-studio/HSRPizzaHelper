//
//  ContentView.swift
//  HSRPizzaHelperWatch Watch App
//
//  Created by Bill Haku on 2023/7/7.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                DailyNoteCards()
            }
            .navigationTitle("home.title")
        }
    }
}
