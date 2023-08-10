//
//  GachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import CoreData
import SwiftUI

// MARK: - GachaView

struct GachaView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink("Get Gacha Record") {
                    GetGachaRecordView()
                }
            }
            Section {
                ForEach(avaliableUIDAndName, id: \.0) { uid, name in
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
            }
        }
        .inlineNavigationTitle("Gacha Record")
    }

    var avaliableUIDAndName: [(String, String?)] {
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

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext
}

// MARK: - AccountGachaView

private struct AccountGachaView: View {
    // MARK: Lifecycle

    init(uid: String, name: String?) {
        self.uid = uid
        self.name = name
        self._gachaItems = .init(
            sortDescriptors: [.init(keyPath: \GachaItemMO.time, ascending: false)],
            predicate: NSPredicate(format: "uid = %@", uid),
            animation: .default
        )
    }

    // MARK: Internal

    var body: some View {
        List {
            Section {
                ForEach(gachaItems) { item in
                    HStack {
                        Text(item.name)
                    }
                }
            }
        }
    }

    // MARK: Private

    private let uid: String
    private let name: String?

    @FetchRequest private var gachaItems: FetchedResults<GachaItemMO>
}
