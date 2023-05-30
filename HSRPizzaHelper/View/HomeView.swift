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
        NavigationView {
            List {
                DailyNoteCards(refreshSubject: dailyNoteRefreshSubject)
            }
            .navigationTitle("home.title")
            .refreshable {
                dailyNoteRefreshSubject.send()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .toast(isPresenting: $alertToastVariable.isDoneButtonTap) {
                AlertToast(
                    displayMode: .alert,
                    type: .complete(.green),
                    title: "account.added.success"
                )
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(alertToastVariable)
    }

    // MARK: Private

    @StateObject private var alertToastVariable = AlertToastVariable()

    @State private var dailyNoteRefreshSubject = PassthroughSubject<(), Never>()
}
