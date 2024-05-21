//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import AlertToast
import Combine
import CoreData
import HBMihoyoAPI
import SwiftUI
import WidgetKit

struct HomeView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                DailyNoteCards()
            }
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .navigationTitle("home.title")
            .toolbar {
                #if os(OSX) || targetEnvironment(macCatalyst)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "arrow.clockwise") { refresh() }
                }
                #endif
            }
            .refreshable { refresh() }
            .toast(isPresenting: $alertToastVariable.isDoneButtonTapped) {
                AlertToast(
                    displayMode: .alert,
                    type: .complete(.green),
                    title: "account.added.success"
                )
            }
        }
        .environmentObject(alertToastVariable)
    }

    func refresh() {
        globalDailyNoteCardRefreshSubject.send(())
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: Private

    @StateObject private var alertToastVariable = AlertToastVariable()
}
