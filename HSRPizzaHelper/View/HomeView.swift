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
                DailyNoteCards()
            }
            .navigationTitle("home.title")
            .refreshable {
                globalDailyNoteCardRefreshSubject.send(())
                WidgetCenter.shared.reloadAllTimelines()
            }
            .toast(isPresenting: $alertToastVariable.isDoneButtonTapped) {
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
}
