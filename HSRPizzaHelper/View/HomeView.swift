//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import HBMihoyoAPI
import SwiftUI
import Combine

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
            }
        }
    }

    private let dailyNoteRefreshSubject = PassthroughSubject<(), Never>()
}
