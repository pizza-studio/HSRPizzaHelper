//
//  AccountGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/11.
//

import HBMihoyoAPI
import SwiftUI

// MARK: - AccountGachaDetailView

struct AccountGachaDetailView: View {
    // MARK: Internal

    let uid: String

    @State var gachaType: GachaType

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

    @State private var rankFilter: RankFilter = .fiveOnly

    @State private var isDisplayOptionShow: Bool = false
    @State private var showTime: Bool = false
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
        if !filteredGachaItemsWithDrawCount.isEmpty {
            ForEach(filteredGachaItemsWithDrawCount, id: \.0.id) { item, drawCount in
                GachaItemBar(item: item, drawCount: drawCount, showTime: showTime)
            }
        } else {
            Text("No data. ")
                .foregroundColor(.secondary)
        }
    }

    var filteredGachaItemsWithDrawCount: [(GachaItemMO, Int)] {
        let drawCounts = calculateGachaItemsDrawCount(gachaItemsResult)
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

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItemMO
    let drawCount: Int
    let showTime: Bool

    var body: some View {
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

func calculateGachaItemsDrawCount(_ gachaItems: FetchedResults<GachaItemMO>) -> [Int] {
    gachaItems.map { item in
        item.rank
    }.enumerated().map { index, rank in
        let theRestOfArray = gachaItems[(index + 1)...]
        if let nextIndexInRest = theRestOfArray
            .firstIndex(where: { $0.rank >= rank }) {
            return nextIndexInRest - index
        } else {
            return gachaItems.count - index
        }
    }
}
