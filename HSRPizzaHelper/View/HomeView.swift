//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Combine
import CoreData
import HBMihoyoAPI
import SwiftUI

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

    // MARK: Private

    private let dailyNoteRefreshSubject = PassthroughSubject<(), Never>()
}
