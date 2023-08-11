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
                NavigationLink("Get Gacha Record") {
                    GetGachaRecordView()
                }
                NavigationLink("Manage Gacha Record") {
                    ManageGachaRecordView()
                }
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
                    Text("No data. get gacha record first. ")
                }
            }
        }
        .inlineNavigationTitle("Gacha Record")
    }

    var availableUIDAndNames: [(String, String?)] {
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
        self.gachaType = .characterEventWarp
    }

    // MARK: Internal

    var body: some View {
        List {
            Section {
                Picker("Gacha Type", selection: $gachaType) {
                    ForEach(GachaType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker("Rank", selection: $rankFilter) {
                    ForEach(RankFilter.allCases, id: \.rawValue) { filter in
                        Text("\(filter.rawValue)").tag(filter)
                    }
                }
            } footer: {
                HStack {
                    Spacer()
                    Button("Display Option") {
                        isDisplayOptionShow.toggle()
                    }
                }
                .font(.footnote)
            }
            Section {
                GachaItemDetail(uid: uid, gachaType: gachaType, rankFilter: rankFilter, showTime: showTime)
            }
        }
        .sheet(isPresented: $isDisplayOptionShow) {
            displayOptionSheet()
        }
    }

    @ViewBuilder
    func displayOptionSheet() -> some View {
        NavigationView {
            List {
                Toggle("Show time", isOn: $showTime)
            }
            .toolbar {
                Button("sys.done") {
                    isDisplayOptionShow.toggle()
                }
            }
        }
        .inlineNavigationTitle("Display Option")
    }

    // MARK: Private

    @State private var gachaType: GachaType = .characterEventWarp
    @State private var rankFilter: RankFilter = .fiveOnly

    @State private var isDisplayOptionShow: Bool = false
    @State private var showTime: Bool = false

    private let uid: String
    private let name: String?
}

// MARK: - RankFilter

private enum RankFilter: Int, CaseIterable {
    case fiveOnly
    case fourAndFive
    case all
}

// MARK: - GachaItemDetail

private struct GachaItemDetail: View {
    // MARK: Lifecycle

    init(uid: String, gachaType: GachaType, rankFilter: RankFilter, showTime: Bool) {
        self.rankFilter = rankFilter
        self._gachaItemsResult = .init(
            sortDescriptors: [.init(keyPath: \GachaItemMO.time, ascending: false)],
            predicate: NSPredicate(format: "uid = %@ AND gachaTypeRawValue = %@", uid, gachaType.rawValue),
            animation: .default
        )
        self.showTime = showTime
    }

    // MARK: Internal

    var body: some View {
        if !gachaItemsWithRank.isEmpty {
            ForEach(gachaItemsWithRank, id: \.0.id) { item, drawCount in
                HStack {
                    ItemIcon(item: item)
                    HStack {
                        Text(item.localizedName)
                        Spacer()
                        VStack(alignment: .trailing) {
                            if item.rank != .three {
                                Text("\(drawCount)")
                                    .font(showTime ? .caption2 : .body)
                            }
                            if showTime {
                                Text(dateFormatter.string(from: item.time))
                                    .foregroundColor(.secondary)
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        } else {
            Text("No data. ")
                .foregroundColor(.secondary)
        }
    }

    var gachaItemsWithRank: [(GachaItemMO, Int)] {
        let drawCounts = gachaItemsResult.map { item in
            item.rank
        }.enumerated().map { index, rank in
            let theRestOfArray = gachaItemsResult[(index + 1)...]
            if let nextIndexInRest = theRestOfArray
                .firstIndex(where: { $0.rank >= rank }) {
                return nextIndexInRest - index
            } else {
                return gachaItemsResult.count - index
            }
        }
        return zip(gachaItemsResult, drawCounts)
            .filter { item, _ in
                switch rankFilter {
                case .all:
                    return true
                case .fourAndFive:
                    return [.five, .four].contains(item.rank)
                case .fiveOnly:
                    return item.rank == .five
                }
            }
    }

    // MARK: Private

    private var showTime: Bool

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>
    private let rankFilter: RankFilter
}

// MARK: - ItemIcon

private struct ItemIcon: View {
    let item: GachaItemMO

    var body: some View {
        Group {
            if let uiImage = item.icon {
                Image(uiImage: uiImage).resizable().scaledToFit()
            } else {
                Image(systemSymbol: .questionmarkCircle).resizable().scaledToFit()
            }
        }
        .background {
            Image(item.rank.backgroundKey)
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(y: 3)
        }
        .clipShape(Circle())
        .contentShape(Circle())
        .frame(width: 35, height: 35)
    }
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()
