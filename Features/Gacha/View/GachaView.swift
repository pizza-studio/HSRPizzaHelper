//
//  GachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import CoreData
import HBMihoyoAPI
import SwiftUI

// MARK: - GachaView

struct GachaView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink("gacha.home.get_gacha_record") {
                    GetGachaRecordView()
                }
                NavigationLink("gacha.home.manage_gacha_record") {
                    ManageGachaRecordView()
                }
            } header: {
                Text("gacha.home.io")
            }
            Section {
                if !availableUIDAndNames.isEmpty {
                    ForEach(availableUIDAndNames, id: \.0) { uid, name in
                        let title: String = {
                            if let name {
                                return "\(name) (\(uid))"
                            } else {
                                return "\(uid)"
                            }
                        }()

                        NavigationLink(title) {
                            AccountGachaView(uid: uid, name: name)
                        }
                    }
                } else {
                    Text("gacha.home.no_data")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("gacha.home.analysis")
            }
        }
        .inlineNavigationTitle("gacha.home.title")
        .onAppear {
            availableUIDAndNames = getAvailableUIDAndNames()
        }
    }

    // MARK: Private

    @State private var availableUIDAndNames: [(String, String?)] = []

    @Environment(\.managedObjectContext) private var viewContext

    private func getAvailableUIDAndNames() -> [(String, String?)] {
        let request =
            NSFetchRequest<NSFetchRequestResult>(entityName: "GachaItemMO")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["uid"]
        if let fetchResult = try? viewContext
            .fetch(request) as? [[String: String]] {
            let uids = fetchResult.compactMap { $0["uid"] }
            return uids.map { uid in
                let request = Account.fetchRequest()
                request.predicate = NSPredicate(format: "uid = %@", uid)
                let accounts = try? viewContext.fetch(request)
                if let name = accounts?.first?.name {
                    return (uid, name)
                } else {
                    return (uid, nil)
                }
            }
        } else {
            return []
        }
    }
}

// MARK: - AccountGachaView
